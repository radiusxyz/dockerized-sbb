#!/bin/bash

set -e

# ✅ Ensure env.sh files exist before execution
if [[ ! -f "$SEQUENCER_EXECUTE_ENV_PATH" ]]; then
    echo "📄 Generating execution env.sh..."
    echo "Hello World"
    echo ./scripts/execute/env_example.sh
    echo $SEQUENCER_EXECUTE_ENV_PATH
    cp ./scripts/execute/env_example.sh "$SEQUENCER_EXECUTE_ENV_PATH"



    sed -i "s|SEQUENCER_INTERNAL_RPC_URL=.*|SEQUENCER_INTERNAL_RPC_URL=${SEQUENCER_INTERNAL_RPC_URL}|" "$SEQUENCER_EXECUTE_ENV_PATH"
    sed -i "s|SEQUENCER_EXTERNAL_RPC_URL=.*|SEQUENCER_EXTERNAL_RPC_URL=${SEQUENCER_EXTERNAL_RPC_URL}|" "$SEQUENCER_EXECUTE_ENV_PATH"
    sed -i "s|SEQUENCER_CLUSTER_RPC_URL=.*|SEQUENCER_CLUSTER_RPC_URL=${SEQUENCER_CLUSTER_RPC_URL}|" "$SEQUENCER_EXECUTE_ENV_PATH"
    sed -i "s|SEQUENCER_PRIVATE_KEY=.*|SEQUENCER_PRIVATE_KEY=${SEQUENCER_PRIVATE_KEY}|" "$SEQUENCER_EXECUTE_ENV_PATH"
    sed -i "s|SEQUENCER_INTERNAL_RPC_URL=.*|SEQUENCER_INTERNAL_RPC_URL=${SEQUENCER_INTERNAL_RPC_URL}|" "$SEQUENCER_EXECUTE_ENV_PATH"

    sed -i "s|KEY_GENERATOR_EXTERNAL_RPC_URL=.*|KEY_GENERATOR_EXTERNAL_RPC_URL=${KEY_GENERATOR_EXTERNAL_RPC_URL}|" "$SEQUENCER_EXECUTE_ENV_PATH"

    sed -i "s|SEEDER_EXTERNAL_RPC_URL=.*|SEEDER_EXTERNAL_RPC_URL=${SEEDER_EXTERNAL_RPC_URL}|" "$SEQUENCER_EXECUTE_ENV_PATH"
fi

if [[ ! -f "$SEQUENCER_RPC_CALL_ENV_PATH" ]]; then
    echo "📄 Generating rpc-call env.sh..."
    cp ./scripts/rpc-call/env_example.sh "$SEQUENCER_RPC_CALL_ENV_PATH"

    sed -i "s|SEQUENCER_INTERNAL_RPC_URL=.*|SEQUENCER_INTERNAL_RPC_URL=${SEQUENCER_INTERNAL_RPC_URL}|" "$SEQUENCER_RPC_CALL_ENV_PATH"

    sed -i "s|LIVENESS_PLATFORM=.*|LIVENESS_PLATFORM=${LIVENESS_PLATFORM}|" "$SEQUENCER_RPC_CALL_ENV_PATH"
    sed -i "s|LIVENESS_SERVICE_PROVIDER=.*|LIVENESS_SERVICE_PROVIDER=${LIVENESS_SERVICE_PROVIDER}|" "$SEQUENCER_RPC_CALL_ENV_PATH"
    sed -i "s|LIVENESS_RPC_URL=.*|LIVENESS_RPC_URL=${LIVENESS_RPC_URL}|" "$SEQUENCER_RPC_CALL_ENV_PATH"
    sed -i "s|LIVENESS_WS_URL=.*|LIVENESS_WS_URL=${LIVENESS_WS_URL}|" "$SEQUENCER_RPC_CALL_ENV_PATH"
    sed -i "s|LIVENESS_CONTRACT_ADDRESS=.*|LIVENESS_CONTRACT_ADDRESS=${LIVENESS_CONTRACT_ADDRESS}|" "$SEQUENCER_RPC_CALL_ENV_PATH"

    sed -i "s|CLUSTER_ID=.*|CLUSTER_ID=${CLUSTER_ID}|" "$SEQUENCER_RPC_CALL_ENV_PATH"

    sed -i "s|VALIDATION_PLATFORM=.*|VALIDATION_PLATFORM=${VALIDATION_PLATFORM}|" "$SEQUENCER_RPC_CALL_ENV_PATH"
    sed -i "s|VALIDATION_SERVICE_PROVIDER=.*|VALIDATION_SERVICE_PROVIDER=${VALIDATION_SERVICE_PROVIDER}|" "$SEQUENCER_RPC_CALL_ENV_PATH"
    sed -i "s|VALIDATION_RPC_URL=.*|VALIDATION_RPC_URL=${VALIDATION_RPC_URL}|" "$SEQUENCER_RPC_CALL_ENV_PATH"
    sed -i "s|VALIDATION_WS_URL=.*|VALIDATION_WS_URL=${VALIDATION_WS_URL}|" "$SEQUENCER_RPC_CALL_ENV_PATH"
    sed -i "s|VALIDATION_SERVICE_MANAGER_CONTRACT_ADDRESS=.*|VALIDATION_SERVICE_MANAGER_CONTRACT_ADDRESS=${VALIDATION_SERVICE_MANAGER_CONTRACT_ADDRESS}|" "$SEQUENCER_RPC_CALL_ENV_PATH"
fi

echo "✅ Environment files are ready."

if [ "$SEQUENCER_MODE" = "init" ]; then

    # ============================
    # 2. Register Operator
    # ============================
    echo "Registering operator..."
    cast send "$OPERATOR_REGISTRY_CONTRACT_ADDRESS" --rpc-url "$RPC_URL" --private-key "$OPERATOR_PRIVATE_KEY" \
    "registerOperator()"

    echo "Checking operator registration..."
    cast call "$OPERATOR_REGISTRY_CONTRACT_ADDRESS" --rpc-url "$RPC_URL" \
    "isEntity(address who)(bool)" "$OPERATOR_ADDRESS"
    echo "Expected output: true"

    # ============================
    # 3. Opt-in to Vault
    # ============================
    echo "Opting in to vault..."
    cast send "$OPERATOR_VAULT_OPT_IN_SERVICE_CONTRACT_ADDRESS" --rpc-url "$RPC_URL" --private-key "$OPERATOR_PRIVATE_KEY" \
    "optIn(address vault)" "$VAULT_CONTRACT_ADDRESS"

    echo "Checking vault opt-in status..."
    cast call "$OPERATOR_VAULT_OPT_IN_SERVICE_CONTRACT_ADDRESS" --rpc-url "$RPC_URL" \
    "isOptedIn(address who, address where)(bool)" "$OPERATOR_ADDRESS" "$VAULT_CONTRACT_ADDRESS"
    echo "Expected output: true"

    # ============================
    # 4. Opt-in to Network
    # ============================
    echo "Opting in to network..."
    cast send "$OPERATOR_NETWORK_OPT_IN_SERVICE_CONTRACT_ADDRESS" --rpc-url "$RPC_URL" --private-key "$OPERATOR_PRIVATE_KEY" \
    "optIn(address network)" "$NETWORK_ADDRESS"

    echo "Checking network opt-in status..."
    cast call "$OPERATOR_NETWORK_OPT_IN_SERVICE_CONTRACT_ADDRESS" --rpc-url "$RPC_URL" \
    "isOptedIn(address who, address where)(bool)" "$OPERATOR_ADDRESS" "$NETWORK_ADDRESS"
    echo "Expected output: true"

    # Liveness Related
    # ============================
    # 5. Register Tx_Orderer
    # ============================
    echo "Registering tx_orderer..."
    cast send "$LIVENESS_CONTRACT_ADDRESS" --rpc-url "$RPC_URL" --private-key "$SEQUENCER_PRIVATE_KEY" \
    "registerTxOrderer(string clusterId)" "$CLUSTER_ID"

    echo "Checking tx_orderer registration..."
    cast call "$LIVENESS_CONTRACT_ADDRESS" --rpc-url "$RPC_URL" \
    "isTxOrdererRegistered(string clusterId, address txOrderer)(bool)" "$CLUSTER_ID" "$SEQUENCER_ADDRESS"
echo "Expected output: true"
    
    # ✅ Apply environment variables dynamically at runtime

    echo "🚀 Running Sequencer Initialization..."
    ./scripts/execute/01_init_sequencer.sh

    echo "✅ Environment variables applied successfully."
    ./scripts/execute/02_run_sequencer.sh &
    sleep 5
    ./scripts/rpc-call/10_initialize.sh

    tail -f /dev/null

elif [ "$SEQUENCER_MODE" = "run" ]; then
    echo "🚀 Running Sequencer..."
    ./scripts/execute/02_run_sequencer.sh &

    tail -f /dev/null

else
    echo "❌ Invalid SEQUENCER_MODE: ${SEQUENCER_MODE}"
    exit 1
fi