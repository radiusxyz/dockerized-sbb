#!/bin/bash

# Exit on error
set -e

# Define repo details
REPO_URL="https://github.com/radiusxyz/symbiotic-middleware-contract"
REPO_DIR="symbiotic-middleware-contract"
BRANCH="feat/renamed"

# Clone the repository and checkout the correct branch
# git clone --branch "$BRANCH" --single-branch "$REPO_URL"
cd "$REPO_DIR"

# Paths
ENV_FILE="../.env"
ENV_SCRIPT="utils/env.sh"

# Ensure .env exists
if [ ! -f "$ENV_FILE" ]; then
  echo "Error: .env file not found in the working directory."
  exit 1
fi

# Replace variables in utils/env.sh with values from .env
temp_file=$(mktemp)
while IFS= read -r line; do
  if [[ $line =~ ^([A-Za-z_]+)=(.*)$ ]]; then
    key="${BASH_REMATCH[1]}"
    value=$(grep -E "^$key=" "$ENV_FILE" | cut -d= -f2-)
    if [[ -n $value ]]; then
      echo "$key=$value" >> "$temp_file"
    else
      echo "$line" >> "$temp_file"
    fi
  else
    echo "$line" >> "$temp_file"
  fi
done < "$ENV_SCRIPT"

mv "$temp_file" "$ENV_SCRIPT"

# Deploy contracts
make build-contracts

make deploy-all

# Export state
./utils/state/export_env.sh > ../final.sh
source ../final.sh

# Start the service
make start &
sleep 10

# Execute blockchain transactions
chmod +x ./utils/gylman.sh
./utils/gylman.sh

# Extract environment variables from final.sh (remove 'export' keyword)
grep 'export ' ../final.sh | sed 's/export //' > ../final_vars.txt

# Prepend final.sh variables to .env
cat ../final_vars.txt "$ENV_FILE" > ../new_env.txt

# Remove duplicate lines (keeping the first occurrence)
awk '!seen[$1]++' FS='=' ../new_env.txt > "$ENV_FILE"

# Clean up
rm ../final_vars.txt ../new_env.txt

echo "Deployment completed successfully, and .env has been updated!"
