#!/bin/bash

set -e

# ✅ Ensure env.sh files exist before execution
if [[ ! -f "$SEEDER_EXECUTE_ENV_PATH" ]]; then
    echo "📄 Generating missing env.sh..."
    cp ./scripts/execute/env_example.sh "$SEEDER_EXECUTE_ENV_PATH"
fi

if [[ ! -f "$SEEDER_RPC_CALL_ENV_PATH" ]]; then
    echo "📄 Generating missing rpc-call env.sh..."
    cp ./scripts/rpc-call/env_example.sh "$SEEDER_RPC_CALL_ENV_PATH"
fi

echo "✅ Environment files are ready."

if [ "$SEEDER_MODE" = "init" ]; then

    # ✅ Apply environment variables dynamically at runtime

    sed -i "s|SEEDER_EXTERNAL_RPC_URL=.*|SEEDER_EXTERNAL_RPC_URL=${SEEDER_EXTERNAL_RPC_URL}|" "$SEEDER_EXECUTE_ENV_PATH"
    sed -i "s|SEEDER_INTERNAL_RPC_URL=.*|SEEDER_INTERNAL_RPC_URL=${SEEDER_INTERNAL_RPC_URL}|" "$SEEDER_EXECUTE_ENV_PATH"
    sed -i "s|SEEDER_INTERNAL_RPC_URL=.*|SEEDER_INTERNAL_RPC_URL=${SEEDER_INTERNAL_RPC_URL}|" "$SEEDER_RPC_CALL_ENV_PATH"

    sed -i "s|LIVENESS_PLATFORM=.*|LIVENESS_PLATFORM=${LIVENESS_PLATFORM}|" "$SEEDER_RPC_CALL_ENV_PATH"
    sed -i "s|LIVENESS_SERVICE_PROVIDER=.*|LIVENESS_SERVICE_PROVIDER=${LIVENESS_SERVICE_PROVIDER}|" "$SEEDER_RPC_CALL_ENV_PATH"
    sed -i "s|LIVENESS_RPC_URL=.*|LIVENESS_RPC_URL=${LIVENESS_RPC_URL}|" "$SEEDER_RPC_CALL_ENV_PATH"
    sed -i "s|LIVENESS_WS_URL=.*|LIVENESS_WS_URL=${LIVENESS_WS_URL}|" "$SEEDER_RPC_CALL_ENV_PATH"
    sed -i "s|LIVENESS_CONTRACT_ADDRESS=.*|LIVENESS_CONTRACT_ADDRESS=${LIVENESS_CONTRACT_ADDRESS}|" "$SEEDER_RPC_CALL_ENV_PATH"

    echo "🚀 Running Seeder Initialization..."
    ./scripts/execute/01_init_seeder.sh

    echo "✅ Environment variables applied successfully."
        ./scripts/execute/02_run_seeder.sh &
        sleep 5
        ./scripts/rpc-call/10_initialize.sh

        tail -f /dev/null

elif [ "$SEEDER_MODE" = "run" ]; then
    echo "🚀 Running Seeder..."
    ./scripts/execute/02_run_seeder.sh &

    tail -f /dev/null

else
    echo "❌ Invalid MODE: ${SEEDER_MODE}"
    exit 1
fi