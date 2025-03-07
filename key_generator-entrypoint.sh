#!/bin/bash

set -e

if [ "$KEY_GENERATOR_MODE" = "init" ]; then
    echo "🚀 Running Key Generator Initialization..."
    ./scripts/execute/01_init_key_generator.sh
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