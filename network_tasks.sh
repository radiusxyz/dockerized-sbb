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
./utils/state/export_env.sh > ../exported_env.sh
source ../exported_env.sh

# Start the service
make start &

# Get the PID of the background process
SERVICE_PID=$!

# Trap SIGINT (Ctrl+C) to kill the background process before exiting
trap "echo 'Stopping service...'; kill $SERVICE_PID; exit" SIGINT

# Sleep to allow service to start
sleep 10

# Execute blockchain transactions
chmod +x ./utils/execute_contract_functions.sh
./utils/execute_contract_functions.sh

# Extract environment variables from exported_env.sh (remove 'export' keyword)
grep 'export ' ../exported_env.sh | sed 's/export //' > ../temp.txt

# Prepend exported_env.sh variables to .env
cat ../temp.txt "$ENV_FILE" > ../new_env.txt

# Remove duplicate lines (keeping the first occurrence)
awk '!seen[$1]++' FS='=' ../new_env.txt > "$ENV_FILE"

# Clean up
rm ../temp.txt ../new_env.txt

echo "Deployment completed successfully, and .env has been updated!"

# Wait for background process to finish
wait $SERVICE_PID
