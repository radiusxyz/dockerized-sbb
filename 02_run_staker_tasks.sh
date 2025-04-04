#!/bin/bash

set -e  # Exit on error

PROJECT_ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE_PATH="$PROJECT_ROOT_PATH/.staker_env"

if [ ! -f "$ENV_FILE_PATH" ]; then
  echo "Error: $ENV_FILE_PATH file not found"
  exit 1
fi

source $ENV_FILE_PATH

#######################################
# Menu
#######################################
echo "========================"
echo " MENU"
echo "========================"
echo "0) Exit"
echo "1) Get token (for testing)"
echo "2) Stake"
echo "------------------------"
read -p "-> Please choose number: " choice

case $choice in
  1)
    echo $TOKEN_CONTRACT_ADDRESS
    echo $VALIDATION_RPC_URL
    echo $TOKEN_CONTRACT_OWNER_PRIVATE_KEY
    echo $STAKER_ADDRESS
    echo $DEPOSIT_AMOUNT

    cast send $TOKEN_CONTRACT_ADDRESS --rpc-url $VALIDATION_RPC_URL --private-key $TOKEN_CONTRACT_OWNER_PRIVATE_KEY \
    "transfer(address,uint256)" $STAKER_ADDRESS $DEPOSIT_AMOUNT

    cast call $TOKEN_CONTRACT_ADDRESS --rpc-url $VALIDATION_RPC_URL \
    "balanceOf(address)(uint256)" $STAKER_ADDRESS
    ;;
  2)
    cast send $TOKEN_CONTRACT_ADDRESS --rpc-url $VALIDATION_RPC_URL --private-key $STAKER_PRIVATE_KEY \
    "approve(address spender, uint256 value)(bool)" $COLLATERAL_CONTRACT_ADDRESS $DEPOSIT_AMOUNT 

    cast call $TOKEN_CONTRACT_ADDRESS --rpc-url $VALIDATION_RPC_URL \
    "allowance(address,address)(uint256)" $STAKER_ADDRESS $COLLATERAL_CONTRACT_ADDRESS

    cast send $COLLATERAL_CONTRACT_ADDRESS --rpc-url $VALIDATION_RPC_URL --private-key $STAKER_PRIVATE_KEY \
    "deposit(address recipient, uint256 amount)(uint256)" $STAKER_ADDRESS $DEPOSIT_AMOUNT 

    cast call $TOKEN_CONTRACT_ADDRESS --rpc-url $VALIDATION_RPC_URL \
    "balanceOf(address)(uint256)" $COLLATERAL_CONTRACT_ADDRESS

    cast send $COLLATERAL_CONTRACT_ADDRESS --rpc-url $VALIDATION_RPC_URL --private-key $STAKER_PRIVATE_KEY \
    "approve(address spender, uint256 value)(bool)" $VAULT_CONTRACT_ADDRESS $DEPOSIT_AMOUNT

    cast send $VAULT_CONTRACT_ADDRESS --rpc-url $VALIDATION_RPC_URL --private-key $STAKER_PRIVATE_KEY \
    "deposit(address onBehalfOf, uint256 amount)(uint256 depositedAmount, uint256 mintedShares)" $STAKER_ADDRESS $DEPOSIT_AMOUNT

    cast call $VAULT_CONTRACT_ADDRESS --rpc-url $VALIDATION_RPC_URL \
    "activeSharesOf(address)(uint256)" $STAKER_ADDRESS

    ;;
  0)
    echo "Exited"
    exit 0
    ;;
  *)
    echo "Wrong number"
    exit 1
    ;;
esac
