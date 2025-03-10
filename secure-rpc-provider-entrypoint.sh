#!/bin/bash

set -e

# ✅ Ensure env.sh files exist before execution
if [[ ! -f "$SECURE_RPC_PROVIDER_EXECUTE_ENV_PATH" ]]; then
    echo "📄 Generating execution env.sh..."
    cp ./scripts/execute/env_example.sh "$SECURE_RPC_PROVIDER_EXECUTE_ENV_PATH"
fi

sed -i "s|SECURE_RPC_PROVIDER_INTERNAL_RPC_URL=.*|SECURE_RPC_PROVIDER_INTERNAL_RPC_URL=${SECURE_RPC_PROVIDER_INTERNAL_RPC_URL}|" "$SECURE_RPC_PROVIDER_EXECUTE_ENV_PATH"
sed -i "s|SECURE_RPC_PROVIDER_CLUSTER_RPC_URL=.*|SECURE_RPC_PROVIDER_CLUSTER_RPC_URL=${SECURE_RPC_PROVIDER_CLUSTER_RPC_URL}|" "$SECURE_RPC_PROVIDER_EXECUTE_ENV_PATH"
sed -i "s|SECURE_RPC_PROVIDER_EXTERNAL_RPC_URL=.*|SECURE_RPC_PROVIDER_EXTERNAL_RPC_URL=${SECURE_RPC_PROVIDER_EXTERNAL_RPC_URL}|" "$SECURE_RPC_PROVIDER_EXECUTE_ENV_PATH"
sed -i "s|SECURE_RPC_PROVIDER_PRIVATE_KEY=.*|SECURE_RPC_PROVIDER_PRIVATE_KEY=${SECURE_RPC_PROVIDER_PRIVATE_KEY}|" "$SECURE_RPC_PROVIDER_EXECUTE_ENV_PATH"

sed -i "s|ROLLUP_ID=.*|ROLLUP_ID=${ROLLUP_ID}|" "$SECURE_RPC_PROVIDER_EXECUTE_ENV_PATH"
sed -i "s|ROLLUP_RPC_URL=.*|ROLLUP_RPC_URL=${ROLLUP_RPC_URL}|" "$SECURE_RPC_PROVIDER_EXECUTE_ENV_PATH"

sed -i "s|KEY_GENERATOR_EXTERNAL_RPC_URL=.*|KEY_GENERATOR_EXTERNAL_RPC_URL=${KEY_GENERATOR_EXTERNAL_RPC_URL}|" "$SECURE_RPC_PROVIDER_EXECUTE_ENV_PATH"

echo "✅ Environment files are ready."

if [ "$SECURE_RPC_PROVIDER_MODE" = "init" ]; then

    # ✅ Apply environment variables dynamically at runtime

    echo "🚀 Running Secure RPC Provider Initialization..."
    ./scripts/execute/01_init_secure_rpc.sh

    echo "✅ Environment variables applied successfully."
    ./scripts/execute/02_run_secure_rpc.sh &
    sleep 5

    tail -f /dev/null

elif [ "$SECURE_RPC_PROVIDER_MODE" = "run" ]; then
    echo "🚀 Running Secure RPC Provider..."
    ./scripts/execute/02_run_secure_rpc.sh &

    tail -f /dev/null

else
    echo "❌ Invalid MODE: ${SECURE_RPC_PROVIDER_MODE}"
    exit 1
fi