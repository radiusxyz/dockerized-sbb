#!/bin/bash

set -e

if [ "$SEQUENCER_MODE" = "init" ]; then
    echo "🚀 Running Sequencer Initialization..."
    ./scripts/execute/01_init_sequencer.sh
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