#!/bin/bash

set -e

if [ "$SEEDER_MODE" = "init" ]; then
    echo "🚀 Running Seeder Initialization..."
    ./scripts/execute/01_init_seeder.sh
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