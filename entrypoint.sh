#!/bin/bash
set -e  # Exit on error

echo "Initializing Seeder/Key Generator..."

DATA_PATH="/app/seeder/data"  # Change for key-generator if needed
CONFIG_FILE_PATH="$DATA_PATH/Config.toml"

# Ensure data path exists
mkdir -p "$DATA_PATH"

# Remove old data without breaking Docker volumes
find "$DATA_PATH" -mindepth 1 -delete

# Initialize the service
if [[ -x "$(command -v seeder)" ]]; then
    echo "Running Seeder initialization..."
    seeder init --path "$DATA_PATH"
elif [[ -x "$(command -v key-generator)" ]]; then
    echo "Running Key Generator initialization..."
    key-generator init --path "$DATA_PATH"
else
    echo "Error: No valid binary found!"
    exit 1
fi

# Update configuration if Config.toml exists
if [[ -f "$CONFIG_FILE_PATH" ]]; then
    sed -i.temp "s|seeder_external_rpc_url = .*|seeder_external_rpc_url = \"$SEEDER_EXTERNAL_RPC_URL\"|g" "$CONFIG_FILE_PATH"
    sed -i.temp "s|seeder_internal_rpc_url = .*|seeder_internal_rpc_url = \"$SEEDER_INTERNAL_RPC_URL\"|g" "$CONFIG_FILE_PATH"
    rm "$CONFIG_FILE_PATH.temp"
else
    echo "Error: Config.toml not found!"
    exit 1
fi

# Start the service
if [[ -x "$(command -v seeder)" ]]; then
    exec seeder start --path "$DATA_PATH"
elif [[ -x "$(command -v key-generator)" ]]; then
    exec key-generator start --path "$DATA_PATH"
fi
