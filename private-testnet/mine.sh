#!/bin/bash

source common.sh

# Logging
LOG=""

###### U S A G E : Help and ERROR ######
function _usage()
{
  cat <<EOF
   mine-wallet $Options
  $*
          Usage: mine.sh
          Options:
                  mine
                  --log             enable detailed output.
                  -t|time           time to mine (minutes).
                  -c|clean          remove old mined files.
                  -d|difficulty     difficulty of mining.
EOF
  exit 0;
}

MINE_TIME=2
CLEAN_RUN=0

while true; do
  case "$1" in
    -l | --log ) LOG=1; shift 1;;
    -t | --time ) MINE_TIME="$2"; shift 2;;
    -c | --clean ) CLEAN_RUN=1; shift 1;;
    -d | --difficulty ) DIFFICULTY="$2"; shift 2;;
    -h | --help ) _usage; shift;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

_log "Logging is enabled"

if [ "$CLEAN_RUN" -ne "0" ]; then
    if [ -e "$PRIVATE_TESTNET_LOCATION" ];
    then
        rm -rf $PRIVATE_TESTNET_LOCATION/node_*
    else
        echo "$PRIVATE_TESTNET_LOCATION does not exist."
        exit 1
    fi
fi

# Stop wallet-rpc
killall -9 monerod -q  > /dev/null
sleep 2s

_log "Running node... "
monerod --p2p-bind-port $NODE_1_P2P_PORT --rpc-bind-port $NODE_1_RPC_PORT --data-dir $PRIVATE_TESTNET_LOCATION/node_01 --p2p-bind-ip $NODE_IP --add-exclusive-node $NODE_IP:$NODE_2_P2P_PORT --add-exclusive-node $NODE_IP:$NODE_3_P2P_PORT --fixed-difficulty $DIFFICULTY --config-file nodes.config --detach  > /dev/null # --start-mining $WALLET_1_ADDRESS
sleep 1s
_log "Running node 2..."
monerod --p2p-bind-port $NODE_2_P2P_PORT --rpc-bind-port $NODE_2_RPC_PORT --data-dir $PRIVATE_TESTNET_LOCATION/node_02 --p2p-bind-ip $NODE_IP --add-exclusive-node $NODE_IP:$NODE_1_P2P_PORT --add-exclusive-node $NODE_IP:$NODE_3_P2P_PORT --fixed-difficulty $DIFFICULTY --config-file nodes.config --detach  > /dev/null # --start-mining $WALLET_2_ADDRESS
sleep 1s
_log "Running node 3..."
monerod --p2p-bind-port $NODE_3_P2P_PORT --rpc-bind-port $NODE_3_RPC_PORT --data-dir $PRIVATE_TESTNET_LOCATION/node_03 --p2p-bind-ip $NODE_IP --add-exclusive-node $NODE_IP:$NODE_1_P2P_PORT --add-exclusive-node $NODE_IP:$NODE_2_P2P_PORT --fixed-difficulty $DIFFICULTY --config-file nodes.config --detach  > /dev/null # --start-mining $WALLET_3_ADDRESS

sleep 4s

_log "Start mining node 1... "
curl http://127.0.0.1:$NODE_1_RPC_PORT/start_mining -d '{"do_background_mining":false,"ignore_battery":true,"miner_address":"'${WALLET_1_ADDRESS}'","threads_count":'${MINER_THREADS}'}' -H 'Content-Type: application/json'   --silent --output /dev/null
_log "Start mining node 2... "
curl http://127.0.0.1:$NODE_2_RPC_PORT/start_mining -d '{"do_background_mining":false,"ignore_battery":true,"miner_address":"'${WALLET_2_ADDRESS}'","threads_count":'${MINER_THREADS}'}' -H 'Content-Type: application/json'   --silent --output /dev/null
_log "Start mining node 3... "
curl http://127.0.0.1:$NODE_3_RPC_PORT/start_mining -d '{"do_background_mining":false,"ignore_battery":true,"miner_address":"'${WALLET_3_ADDRESS}'","threads_count":'${MINER_THREADS}'}' -H 'Content-Type: application/json'   --silent --output /dev/null

_log "Mining for ${MINE_TIME} minutes..."
sleep ${MINE_TIME}m;

# Stop mining
_log "Stop mining node 1... "
curl http://127.0.0.1:$NODE_1_RPC_PORT/stop_mining -H 'Content-Type: application/json'    --silent --output /dev/null
_log "Stop mining node 2... "
curl http://127.0.0.1:$NODE_2_RPC_PORT/stop_mining -H 'Content-Type: application/json'    --silent --output /dev/null
_log "Stop mining node 3... "
curl http://127.0.0.1:$NODE_3_RPC_PORT/stop_mining -H 'Content-Type: application/json'    --silent --output /dev/null


sleep 5s
# Stop wallet-rpc
killall -9 monerod -q