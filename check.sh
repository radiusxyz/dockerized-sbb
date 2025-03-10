#!/bin/bash

RPC_URL="https://ethereum-rpc.publicnode.com"

VALIDATION_SERVICE_MANAGER_CONTRACT_ADDRESS="0x1f0A1818c1a2ECb84f46211e78e7dEC22d9BE737"
LIVENESS_CONTRACT_ADDRESS="0xD805700cDc191F52C7A78f72d238194f0FDeA76C"
CLUSTER_ID="radius_network"

NETWORK_ADDRESS="0xfCa0128A19A5c06b0148c27ee7623417a11BaAbd"
SUBNETWORK=$NETWORK_ADDRESS"000000000000000000000000"

OPERATOR_REGISTRY_CONTRACT_ADDRESS="0xAd817a6Bc954F678451A71363f04150FDD81Af9F"
OPERATOR_NETWORK_OPT_IN_SERVICE_CONTRACT_ADDRESS="0x7133415b33B438843D581013f98A08704316633c"
OPERATOR_VAULT_OPT_IN_SERVICE_CONTRACT_ADDRESS="0xb361894bC06cbBA7Ea8098BF0e32EB1906A5F891"

declare -A VAULTS=(
  ["Swell_wBTC"]="0x9e405601B645d3484baeEcf17bBF7aD87680f6e8"
  ["Etherfi_wstETH"]="0x450a90fdEa8B87a6448Ca1C87c88Ff65676aC45b"
  ["Gauntlet_cbETH"]="0xB8Fd82169a574eB97251bF43e443310D33FF056C"
  ["Mev_wstETH"]="0x446970400e1787814CA050A4b45AE9d21B3f7EA7"
  ["Mev_wstETH2"]="0x4e0554959A631B3D3938ffC158e0a7b2124aF9c5"
  ["P2P_wstETH"]="0x7b276aAD6D2ebfD7e270C5a2697ac79182D9550E"
)

declare -A DELEGATOR=(
  ["Swell_wBTC"]="0x60565109dbe429c51fE2502218938aB61462E5f5"
  ["Etherfi_wstETH"]="0xd6c4b4267BFB908BBdf8C9BDa7d0Ae517aA145b0"
  ["Gauntlet_cbETH"]="0x4366f2a20Fe4d6ba4C29FAfbF406CD2aE969A77a"
  ["Mev_wstETH"]="0xA6851E43FA955753ee90a72c59030e0423F27E41"
  ["Mev_wstETH2"]="0x1f16782a9b75FfFAD87e7936791C672bdDBCb8Ec"
  ["P2P_wstETH"]="0xdc439a51AB1C1D4DB0CD09A009f94eC4D127D93c"
)

declare -A TOKENS=(
  ["wBTC"]="0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599"
  ["wstETH"]="0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0"
  ["cbETH"]="0xBe9895146f7AF43049ca1c1AE358B0541Ea49704"
)

teams=(
  "Radius2|0x00e769E7067143fbDB962258e78FA450eD9Ec7E6|0xe9603766126176e061b648AF56A0E12d8ed7b23E"
  "Radius|0xaE41878469D385faDA7C07f74C4849c7CF9B77F6|0x0d66b68bfd3d369b8479dd09acc880f9e42Fa718"

  "A41|0x93fDa90D946243B6A1823d24344D0b8F8ED87Edb|0x136BE88CDDc309595CA864aD93AFC888AF3010ae"
  "Blockdaemon|0x888F7454E65D213C89bA92020e0d716428898f7f|0xbf4EE5334af652d8540bd911668d5Cd1aFa817e3"
  "Chorus One|0xd741F826c60DaCEBB8835278E0F18f1C5DD4c6d0|0x748bc55D35d209322a5e3b1747dde505eCe245C3"
  "Everstake|0x6f64DeCffDE23AA598724325202f8324c231A682|0x30E30c76E111BF62Aa69e542981F6995C0017259"
  "Finoa|0x2A21EaAe1519D852296a158549416442fbb1fdD2|0xA65B54B70933670A54551F4D96fce20334c77004"
  "HashKey|0xe8e54EA992a3f8aaED7f05de7C1487855674A3cf|0x2eBB982D689b5b0d848C0b4f276834eA4a7998E5"
  # "Infrstone||"
  "Kiln|0xfF645D02C79141424fb4F8bBB5e494f05067c08B|0x364ab3dF2A2b67C6B37483aac4caE7d1262DF287"
  "Luganodes|0xAC128Aa884c64cbE6Afecf5c006D51C2bb1Bf819|0xB98044C764525137b07B1Ff4B8ac8057485250C8"
  "Nodeinfra|0x9321d38c355d1D8cB9dbfC05a5c0f347b1DDa46a|0x7d2687948a3DDc56928AEFCB00ac01c810792571"
  # "P2P|0x087c25f83ED20bda587CFA035ED0c96338D4660f|0x087c25f83ED20bda587CFA035ED0c96338D4660f"
  "Pier Two|0x51B6D824bd35AeD4FD1a9E253E41Dc7C9feeFa30|0x3364dED2B43681d9f14Fc1a622d3820a4FfD805c"
  "Stakely|0x57A58ff6f5724d29C05a4d0B29d07b82817C50D5|0x3feb5D40Bb15457F838B57cc71c45Ef2b632b0d9"
  "Stakin|0x5d24dBA4ccdE2C5B7bC5b609c6a3D5150acB9447|0x34A6612cd270AD475C73fa9F3C18Ac3B1a14E8B6"
)

declare -A team_vaults=(
  ["Radius2"]="Swell_wBTC:${VAULTS[Swell_wBTC]}"
  ["Radius"]="Swell_wBTC:${VAULTS[Swell_wBTC]},Gauntlet_cbETH:${VAULTS[Gauntlet_cbETH]}"

  ["A41"]="Swell_wBTC:${VAULTS[Swell_wBTC]}"
  ["Blockdaemon"]="Etherfi_wstETH:${VAULTS[Etherfi_wstETH]}"
  ["Chorus One"]="Swell_wBTC:${VAULTS[Swell_wBTC]},Gauntlet_cbETH:${VAULTS[Gauntlet_cbETH]},Mev_wstETH:${VAULTS[Mev_wstETH]}"
  ["Everstake"]="Swell_wBTC:${VAULTS[Swell_wBTC]}"
  ["Finoa"]="Swell_wBTC:${VAULTS[Swell_wBTC]}"
  ["HashKey"]="Swell_wBTC:${VAULTS[Swell_wBTC]}"
  # ["Infrstone"]="Swell_wBTC:${VAULTS[Swell_wBTC]}"
  ["Kiln"]="Swell_wBTC:${VAULTS[Swell_wBTC]},Etherfi_wstETH:${VAULTS[Etherfi_wstETH]},Gauntlet_cbETH:${VAULTS[Gauntlet_cbETH]}"
  ["Luganodes"]="Swell_wBTC:${VAULTS[Swell_wBTC]},Gauntlet_cbETH:${VAULTS[Gauntlet_cbETH]}"
  ["Nodeinfra"]="Mev_wstETH:${VAULTS[Mev_wstETH]}"
  # ["P2P"]="Swell_wBTC:${VAULTS[Swell_wBTC]},Etherfi_wstETH:${VAULTS[Etherfi_wstETH]}"
  ["Pier Two"]="Swell_wBTC:${VAULTS[Swell_wBTC]},Etherfi_wstETH:${VAULTS[Etherfi_wstETH]},Gauntlet_cbETH:${VAULTS[Gauntlet_cbETH]}"
  ["Stakely"]="Swell_wBTC:${VAULTS[Swell_wBTC]}"
  ["Stakin"]="Swell_wBTC:${VAULTS[Swell_wBTC]}"
)

check_team() {
  local team_name=$1
  local operator_address=$2
  local operating_address=$3

  echo "=============================="
  echo "team: $team_name"
  echo "=============================="

  result1=$(cast call $LIVENESS_CONTRACT_ADDRESS --rpc-url $RPC_URL \
    "isSequencerRegistered(string clusterId, address operating)(bool)" $CLUSTER_ID $operating_address)
  echo "1. Check register sequencer - ('$CLUSTER_ID', $operating_address): $result1"

  result2=$(cast call $OPERATOR_REGISTRY_CONTRACT_ADDRESS --rpc-url $RPC_URL \
    "isEntity(address who)(bool)" $operator_address)
  echo "2. Check register operator - ($operator_address): $result2"

  result3=$(cast call $OPERATOR_NETWORK_OPT_IN_SERVICE_CONTRACT_ADDRESS --rpc-url $RPC_URL \
    "isOptedIn(address who, address where)(bool)" $operator_address $NETWORK_ADDRESS)
  echo "3. Check Optin to network - ($operator_address, $NETWORK_ADDRESS): $result3"

  vaults=${team_vaults[$team_name]}
  IFS=',' read -r -a vault_array <<< "$vaults"

  echo "4. Check Optin to Vaults and operator network shares"
  for vault_entry in "${vault_array[@]}"; do
    IFS=':' read -r vault_name vault_address <<< "$vault_entry"
    
    result_vault=$(cast call $OPERATOR_VAULT_OPT_IN_SERVICE_CONTRACT_ADDRESS --rpc-url $RPC_URL \
      "isOptedIn(address who, address where)(bool)" $operator_address $vault_address)
    echo " - $vault_name ($vault_address): $result_vault"

    for delegator_name in "${!DELEGATOR[@]}"; do
      delegator_address=${DELEGATOR[$delegator_name]}
      
      if [ "$vault_name" == "$delegator_name" ]; then
        result_share=$(cast call $delegator_address --rpc-url $RPC_URL \
          "operatorNetworkShares(bytes32 subnetwork, address operator)(uint256)" $SUBNETWORK $operator_address)
        
        echo "   * Share amount - $result_share"
      fi
    done
  done

  echo "6. Check register operator in middleware contract"
  cast_output=$(cast call $VALIDATION_SERVICE_MANAGER_CONTRACT_ADDRESS --rpc-url $RPC_URL \
  "getCurrentOperatorInfos()((address, address, (address, uint256)[])[])")

  if echo "$cast_output" | grep -q "$operator_address"; then
    echo "   * It exists in the middleware contract."

    echo "7. Check staking amount for each token"
    for token_name in "${!TOKENS[@]}"; do
      token_address=${TOKENS[$token_name]}
      
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

########################

result=$(cast call "$VALIDATION_SERVICE_MANAGER_CONTRACT_ADDRESS" --rpc-url "$RPC_URL" \
    "isActiveToken(address token)(bool)" $TOKEN_CONTRACT_ADDRESS)

if [[ "$result" == "true" ]]; then
    echo "The vault is already registered"
else
    result=$(cast send $VALIDATION_SERVICE_MANAGER_CONTRACT_ADDRESS --rpc-url $RPC_URL --private-key $NETWORK_PRIVATE_KEY \
    "registerToken(address tokenAddress)" $TOKEN_CONTRACT_ADDRESS)

    echo "Completed registering the token"
fi
