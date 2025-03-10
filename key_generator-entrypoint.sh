#!/bin/bash

set -e

# ✅ Ensure env.sh files exist before execution
if [[ ! -f "$KEY_GENERATOR_EXECUTE_ENV_PATH" ]]; then
    echo "📄 Generating execution env.sh..."
    cp ./scripts/execute/env_example.sh "$KEY_GENERATOR_EXECUTE_ENV_PATH"
fi

sed -i "s|KEY_GENERATOR_INTERNAL_RPC_URL=.*|KEY_GENERATOR_INTERNAL_RPC_URL=${KEY_GENERATOR_INTERNAL_RPC_URL}|" "$KEY_GENERATOR_EXECUTE_ENV_PATH"
sed -i "s|KEY_GENERATOR_CLUSTER_RPC_URL=.*|KEY_GENERATOR_CLUSTER_RPC_URL=${KEY_GENERATOR_CLUSTER_RPC_URL}|" "$KEY_GENERATOR_EXECUTE_ENV_PATH"
sed -i "s|KEY_GENERATOR_EXTERNAL_RPC_URL=.*|KEY_GENERATOR_EXTERNAL_RPC_URL=${KEY_GENERATOR_EXTERNAL_RPC_URL}|" "$KEY_GENERATOR_EXECUTE_ENV_PATH"
sed -i "s|KEY_GENERATOR_PRIVATE_KEY=.*|KEY_GENERATOR_PRIVATE_KEY=${KEY_GENERATOR_PRIVATE_KEY}|" "$KEY_GENERATOR_EXECUTE_ENV_PATH"

if [[ ! -f "$KEY_GENERATOR_RPC_CALL_ENV_PATH" ]]; then
    echo "📄 Generating rpc-call env.sh..."
    cp ./scripts/rpc-call/env_example.sh "$KEY_GENERATOR_RPC_CALL_ENV_PATH"
fi

sed -i "s|KEY_GENERATOR_INTERNAL_RPC_URL=.*|KEY_GENERATOR_INTERNAL_RPC_URL=${KEY_GENERATOR_INTERNAL_RPC_URL}|" "$KEY_GENERATOR_RPC_CALL_ENV_PATH"
sed -i "s|KEY_GENERATOR_CLUSTER_RPC_URL=.*|KEY_GENERATOR_CLUSTER_RPC_URL=${KEY_GENERATOR_CLUSTER_RPC_URL}|" "$KEY_GENERATOR_RPC_CALL_ENV_PATH"
sed -i "s|KEY_GENERATOR_EXTERNAL_RPC_URL=.*|KEY_GENERATOR_EXTERNAL_RPC_URL=${KEY_GENERATOR_EXTERNAL_RPC_URL}|" "$KEY_GENERATOR_RPC_CALL_ENV_PATH"
sed -i "s|KEY_GENERATOR_ADDRESS=.*|KEY_GENERATOR_ADDRESS=${KEY_GENERATOR_ADDRESS}|" "$KEY_GENERATOR_RPC_CALL_ENV_PATH"

echo "✅ Environment files are ready."

if [ "$KEY_GENERATOR_MODE" = "init" ]; then

    echo "🚀 Running Key Generator Initialization..."
    ./scripts/execute/01_init_key_generator.sh

    echo "✅ Environment variables applied successfully."
        ./scripts/execute/02_run_key_generator.sh &
        sleep 5
        ./scripts/rpc-call/10_initialize.sh

        tail -f /dev/null

elif [ "$KEY_GENERATOR_MODE" = "run" ]; then
    echo "🚀 Running Key Generator..."
    ./scripts/execute/02_run_key_generator.sh &

    tail -f /dev/null

else
    echo "❌ Invalid MODE: ${KEY_GENERATOR_MODE}"
    exit 1
fi