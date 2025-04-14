#!/bin/bash

VALIDATION_RPC_URL="http://35.189.33.95:8545"

NETWORK_ADDRESS="0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
SUBNETWORK=$NETWORK_ADDRESS"000000000000000000000000"

VAULTS=("VAULT_1")
VAULT_ADDRESSES=("0x4ce789c1774c852FA9E248E8EcE4E4e936E92E73")
DELEGATORS=("0x04950543b6417703a81B401046F54C53E2819434")
TOKENS=("0x4ed7c70F96B99c776995fB64377f0d4aB3B0e1C1")
NETWORK_MAX_LIMITS=("4725000000")


for i in "${!VAULTS[@]}"; do
  name="${VAULTS[$i]}"
  vault="${VAULT_ADDRESSES[$i]}"
  delegator="${DELEGATORS[$i]}"
  token="${TOKENS[$i]}"
  max_limit="${NETWORK_MAX_LIMITS[$i]}"

  echo "Name: $name"
  echo "  VAULT Address: $vault"
  echo "  DELEGATOR Address: $delegator"
  echo "  TOKEN Address: $token"
  echo "  SUBNETWORK: $SUBNETWORK"

  if [ -n "$delegator" ]; then
    max_network_limit=$(cast call "$delegator" --rpc-url "$VALIDATION_RPC_URL" \
      "maxNetworkLimit(bytes32)(uint256)" "$SUBNETWORK" 2>/dev/null)
    echo "  NETWORK_MAX_LIMIT: ${max_network_limit:-Error fetching data}"

    total_operator_network_shares=$(cast call "$delegator" --rpc-url "$VALIDATION_RPC_URL" \
      "totalOperatorNetworkShares(bytes32)(uint256)" "$SUBNETWORK" 2>/dev/null)
    echo "  Total operator network shares: ${total_operator_network_shares:-Error fetching data}"
  fi

  echo ""
done