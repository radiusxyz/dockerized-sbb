#!/bin/bash

##########################################################################################

RPC_URL="http://192.168.68.57:8545"

VALIDATION_SERVICE_MANAGER_CONTRACT_ADDRESS="0x0E801D84Fa97b50751Dbf25036d067dCf18858bF"
LIVENESS_SERVICE_MANAGER_CONTRACT_ADDRESS="0x4826533B4897376654Bb4d4AD88B7faFD0C98528"
CLUSTER_ID="radius_cluster"

NETWORK_ADDRESS="0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
SUBNETWORK=$NETWORK_ADDRESS"000000000000000000000000"

OPERATOR_REGISTRY_CONTRACT_ADDRESS="0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9"
OPERATOR_NETWORK_OPT_IN_SERVICE_CONTRACT_ADDRESS="0x8A791620dd6260079BF849Dc5567aDC3F2FdC318"
OPERATOR_VAULT_OPT_IN_SERVICE_CONTRACT_ADDRESS="0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6"

# VAULT Info (name|vault address|delegator address)
vault_info_list=(
  "VAULT_1|0x8b5292bd436EEEC2e87b25Ab823940Cdfa6f40ef|0x04950543b6417703a81B401046F54C53E2819434"
)

# TOKEN Info (name|address)
tokens=(
  "STETH|0x4ed7c70F96B99c776995fB64377f0d4aB3B0e1C1"
)

# TEAM Info (name|operator address|tx_orderer address)
teams=(
  "ROLLUP_1|0x14dC79964da2C08b23698B3D3cc7Ca32193d9955|0x976EA74026E726554dB657fA54763abd0C3a0aa9"
)

# VAULT mapping (team name|vault name)
team_vaults=(
  "ROLLUP_1|VAULT_1"
)

##########################################################################################

check_team() {
  local team_name=$1
  local operator_address=$2
  local tx_orderer=$3

  echo "=============================="
  echo "team: $team_name"
  echo "=============================="

  result1=$(cast call $LIVENESS_SERVICE_MANAGER_CONTRACT_ADDRESS --rpc-url $RPC_URL \
    "isTxOrdererRegistered(string clusterId, address operating)(bool)" $CLUSTER_ID $tx_orderer)
  echo "1. Check register tx orderer - ('$CLUSTER_ID', $tx_orderer): $result1"

  result2=$(cast call $OPERATOR_REGISTRY_CONTRACT_ADDRESS --rpc-url $RPC_URL \
    "isEntity(address who)(bool)" $operator_address)
  echo "2. Check register operator - ($operator_address): $result2"

  result3=$(cast call $OPERATOR_NETWORK_OPT_IN_SERVICE_CONTRACT_ADDRESS --rpc-url $RPC_URL \
    "isOptedIn(address who, address where)(bool)" $operator_address $NETWORK_ADDRESS)
  echo "3. Check Optin to network - ($operator_address, $NETWORK_ADDRESS): $result3"

  echo "4. Check Optin to Vaults and operator network shares"

  for mapping in "${team_vaults[@]}"; do
    IFS="|" read -r team vault_name <<< "$mapping"
    if [ "$team" == "$team_name" ]; then

      for vault_info in "${vault_info_list[@]}"; do
        IFS="|" read -r vn vault_address delegator_address <<< "$vault_info"
        if [ "$vn" == "$vault_name" ]; then

          result_vault=$(cast call $OPERATOR_VAULT_OPT_IN_SERVICE_CONTRACT_ADDRESS --rpc-url $RPC_URL \
            "isOptedIn(address who, address where)(bool)" $operator_address $vault_address)
          echo " - $vault_name ($vault_address): $result_vault"

          result_share=$(cast call $delegator_address --rpc-url $RPC_URL \
            "operatorNetworkShares(bytes32 subnetwork, address operator)(uint256)" $SUBNETWORK $operator_address)
          echo "   * Share amount - $result_share"
        fi
      done
    fi
  done

  echo "6. Check register operator in middleware contract"
  cast_output=$(cast call $VALIDATION_SERVICE_MANAGER_CONTRACT_ADDRESS --rpc-url $RPC_URL \
    "getCurrentOperatorInfos()((address, address, (address, uint256)[])[])")

  if echo "$cast_output" | grep -q "$operator_address"; then
    echo "   * It exists in the middleware contract."

    echo "7. Check staking amount for each token"
    for token_entry in "${tokens[@]}"; do
      IFS="|" read -r token_name token_address <<< "$token_entry"

      staking_amount=$(cast call $VALIDATION_SERVICE_MANAGER_CONTRACT_ADDRESS --rpc-url $RPC_URL \
        "getCurrentOperatorTokenStake(address operator, address token)(uint256)" \
        $operator_address $token_address)

      echo "   * $token_name ($token_address) - $staking_amount"
    done
  else
    echo "Address $operator_address does not exist in the middleware contract."
  fi

  echo ""
}

for team in "${teams[@]}"; do
  IFS="|" read -r name operator operating <<< "$team"
  check_team "$name" "$operator" "$operating"
done