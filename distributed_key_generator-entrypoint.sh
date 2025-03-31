#!/bin/bash

set -e

#######################################
# Utility Functions
#######################################
replace_env_var() {
  local file=$1
  local key=$2
  local value=$3
  sed -i "s|^${key}=.*|${key}=${value}|" "$file"
}

ensure_env_file() {
  local target_path=$1
  local example_path=$2

  if [[ ! -f "$target_path" ]]; then
    echo "📄 Creating $target_path from example..."
    cp "$example_path" "$target_path"
  fi
}

#######################################
# 1. Prepare Execution env
#######################################

ensure_env_file "$KEY_GENERATOR_EXECUTE_ENV_PATH" "./scripts/execute/env_example.sh"
replace_env_var "$KEY_GENERATOR_EXECUTE_ENV_PATH" "KEY_GENERATOR_INTERNAL_RPC_URL" "$KEY_GENERATOR_INTERNAL_RPC_URL"
replace_env_var "$KEY_GENERATOR_EXECUTE_ENV_PATH" "KEY_GENERATOR_CLUSTER_RPC_URL" "$KEY_GENERATOR_CLUSTER_RPC_URL"
replace_env_var "$KEY_GENERATOR_EXECUTE_ENV_PATH" "KEY_GENERATOR_EXTERNAL_RPC_URL" "$KEY_GENERATOR_EXTERNAL_RPC_URL"
replace_env_var "$KEY_GENERATOR_EXECUTE_ENV_PATH" "KEY_GENERATOR_PRIVATE_KEY" "$KEY_GENERATOR_PRIVATE_KEY"


ensure_env_file "$KEY_GENERATOR_RPC_CALL_ENV_PATH" "./scripts/rpc-call/env_example.sh"
replace_env_var "$KEY_GENERATOR_RPC_CALL_ENV_PATH" "KEY_GENERATOR_INTERNAL_RPC_URL" "$KEY_GENERATOR_INTERNAL_RPC_URL"
replace_env_var "$KEY_GENERATOR_RPC_CALL_ENV_PATH" "KEY_GENERATOR_CLUSTER_RPC_URL" "$KEY_GENERATOR_CLUSTER_RPC_URL"
replace_env_var "$KEY_GENERATOR_RPC_CALL_ENV_PATH" "KEY_GENERATOR_EXTERNAL_RPC_URL" "$KEY_GENERATOR_EXTERNAL_RPC_URL"
replace_env_var "$KEY_GENERATOR_RPC_CALL_ENV_PATH" "KEY_GENERATOR_ADDRESS" "$KEY_GENERATOR_ADDRESS"

echo "All environment files are prepared."

#######################################
# 3. Run Mode Handling
#######################################
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