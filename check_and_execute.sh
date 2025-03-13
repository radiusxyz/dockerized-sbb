#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    set -o allexport
    source .env
    set +o allexport
else
    echo "⚠️ .env file not found! Exiting..."
    exit 1
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

# 1. Register Operator
check_and_execute \
    "cast call $OPERATOR_REGISTRY_CONTRACT_ADDRESS --rpc-url $LIVENESS_RPC_URL 'isEntity(address who)(bool)' $OPERATOR_ADDRESS" \
    "true" \
    "cast send $OPERATOR_REGISTRY_CONTRACT_ADDRESS --rpc-url $LIVENESS_RPC_URL --private-key $OPERATOR_PRIVATE_KEY 'registerOperator()'" \
    "Registering Operator"

# 2. Opt-in to Vault
check_and_execute \
    "cast call $OPERATOR_VAULT_OPT_IN_SERVICE_CONTRACT_ADDRESS --rpc-url $LIVENESS_RPC_URL 'isOptedIn(address who, address where)(bool)' $OPERATOR_ADDRESS $VAULT_CONTRACT_ADDRESS" \
    "true" \
    "cast send $OPERATOR_VAULT_OPT_IN_SERVICE_CONTRACT_ADDRESS --rpc-url $LIVENESS_RPC_URL --private-key $OPERATOR_PRIVATE_KEY 'optIn(address vault)' $VAULT_CONTRACT_ADDRESS" \
    "Opt-in to Vault"

# 3. Opt-in to Network
check_and_execute \
    "cast call $OPERATOR_NETWORK_OPT_IN_SERVICE_CONTRACT_ADDRESS --rpc-url $LIVENESS_RPC_URL 'isOptedIn(address who, address where)(bool)' $OPERATOR_ADDRESS $NETWORK_ADDRESS" \
    "true" \
    "cast send $OPERATOR_NETWORK_OPT_IN_SERVICE_CONTRACT_ADDRESS --rpc-url $LIVENESS_RPC_URL --private-key $OPERATOR_PRIVATE_KEY 'optIn(address network)' $NETWORK_ADDRESS" \
    "Opt-in to Network"

# 4. Register Tx_Orderer
# check_and_execute \
#     "cast call $LIVENESS_CONTRACT_ADDRESS --rpc-url $LIVENESS_RPC_URL 'isTxOrdererRegistered(string clusterId, address txOrderer)(bool)' $CLUSTER_ID $SEQUENCER_ADDRESS" \
#     "true" \
#     "cast send $LIVENESS_CONTRACT_ADDRESS --rpc-url $LIVENESS_RPC_URL --private-key $SEQUENCER_PRIVATE_KEY 'registerTxOrderer(string clusterId)' $CLUSTER_ID" \
#     "Registering Tx_Orderer"

echo "✅ All necessary steps have been completed."
