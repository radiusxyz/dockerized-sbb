#!/bin/bash

set -e

if [ "$SECURE_RPC_PROVIDER_MODE" = "init" ]; then
    echo "🚀 Running Secure RPC Provider Initialization..."
    ./scripts/execute/01_init_secure_rpc.sh
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