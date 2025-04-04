#!/bin/bash

source .operator_env
# Step 1: Check if `cast` is installed
if ! command -v cast &> /dev/null; then
    echo "⚠️ Foundry's 'cast' command is not installed. Installing Foundry..."
    curl -L https://foundry.paradigm.xyz | bash
    source "$HOME/.bashrc" || source "$HOME/.zshrc"
    foundryup
else
    echo "✅ 'cast' command found."
fi

# Step 2: Check if `cast` version matches the required nightly version
REQUIRED_VERSION="cast 0.2.0 (5b7e4cb 2023-12-02T00:23:06.394266000Z)"
CURRENT_VERSION=$(cast --version)

echo "🔍 Current version..." $CURRENT_VERSION
 
if [[ "$CURRENT_VERSION" != "$REQUIRED_VERSION" ]]; then
    echo "⚠️ Incorrect Foundry version detected: $CURRENT_VERSION"
    echo "Updating Foundry to required version: $REQUIRED_VERSION..."
    foundryup -v "nightly-5b7e4cb3c882b28f3c32ba580de27ce7381f415a"
else
    echo "✅ Foundry is already at the required version: $CURRENT_VERSION. Skipping update..."
fi

# Function to check a condition and execute a command only if needed
check_and_execute() {
    local check_command=$1
    local expected_output=$2
    local send_command=$3
    local description=$4

    echo "Checking: $description"
    result=$(eval "$check_command")

    if [[ "$result" == "$expected_output" ]]; then
        echo "✅ Already set: $description"
    else
        echo "❌ Check failed. Executing: $description"
        eval "$send_command"
    fi
}

echo $OPERATOR_REGISTRY_CONTRACT_ADDRESS
echo $VALIDATION_RPC_URL
echo $OPERATOR_ADDRESS
# 1. Register Operator
check_and_execute \
    "cast call $OPERATOR_REGISTRY_CONTRACT_ADDRESS --rpc-url $VALIDATION_RPC_URL 'isEntity(address who)(bool)' $OPERATOR_ADDRESS" \
    "true" \
    "cast send $OPERATOR_REGISTRY_CONTRACT_ADDRESS --rpc-url $VALIDATION_RPC_URL --private-key $OPERATOR_PRIVATE_KEY 'registerOperator()'" \
    "Registering Operator"

# 2. Opt-in to Vault
check_and_execute \
    "cast call $OPERATOR_VAULT_OPT_IN_SERVICE_CONTRACT_ADDRESS --rpc-url $VALIDATION_RPC_URL 'isOptedIn(address who, address where)(bool)' $OPERATOR_ADDRESS $VAULT_CONTRACT_ADDRESS" \
    "true" \
    "cast send $OPERATOR_VAULT_OPT_IN_SERVICE_CONTRACT_ADDRESS --rpc-url $VALIDATION_RPC_URL --private-key $OPERATOR_PRIVATE_KEY 'optIn(address vault)' $VAULT_CONTRACT_ADDRESS" \
    "Opt-in to Vault"

# 3. Opt-in to Network
check_and_execute \
    "cast call $OPERATOR_NETWORK_OPT_IN_SERVICE_CONTRACT_ADDRESS --rpc-url $VALIDATION_RPC_URL 'isOptedIn(address who, address where)(bool)' $OPERATOR_ADDRESS $NETWORK_ADDRESS" \
    "true" \
    "cast send $OPERATOR_NETWORK_OPT_IN_SERVICE_CONTRACT_ADDRESS --rpc-url $VALIDATION_RPC_URL --private-key $OPERATOR_PRIVATE_KEY 'optIn(address network)' $NETWORK_ADDRESS" \
    "Opt-in to Network"

# 4. Register Tx_Orderer
check_and_execute \
    "cast call $LIVENESS_SERVICE_MANAGER_CONTRACT_ADDRESS --rpc-url $LIVENESS_RPC_URL 'isTxOrdererRegistered(string clusterId, address txOrderer)(bool)' $CLUSTER_ID $TX_ORDERER_ADDRESS" \
    "true" \
    "cast send $LIVENESS_SERVICE_MANAGER_CONTRACT_ADDRESS --rpc-url $LIVENESS_RPC_URL --private-key $TX_ORDERER_PRIVATE_KEY 'registerTxOrderer(string clusterId)' $CLUSTER_ID" \
    "Registering Tx_Orderer"

echo "✅ All necessary steps have been completed."
