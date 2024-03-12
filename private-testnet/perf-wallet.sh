#!/bin/bash

source common.sh

# Logging
LOG=""

###### U S A G E : Help and ERROR ######
function _usage()
{
  cat <<EOF
   perf-wallet $Options
  $*
          Usage: perf-wallet
          Options:
                  benchmark daemons with different wallets.
                  --log         enable detailed output.
EOF
  exit 0;
}

# Log function
clean_wallet_cache(){
    # clean cache
    rm $PRIVATE_TESTNET_LOCATION/*.bin 2> /dev/null
}

while true; do
  case "$1" in
    -l | --log ) LOG=1; shift 1;;
    -h | --help ) _usage; shift;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

_log "Logging is enabled"

# Stop wallet-rpc
killall -9 monerod -q
sleep 5s

_log "Running node... "
monerod --p2p-bind-port $NODE_1_P2P_PORT --rpc-bind-port $NODE_1_RPC_PORT --data-dir $PRIVATE_TESTNET_LOCATION/node_01 --p2p-bind-ip $NODE_IP --add-exclusive-node $NODE_IP:$NODE_2_P2P_PORT --add-exclusive-node $NODE_IP:$NODE_3_P2P_PORT --fixed-difficulty $DIFFICULTY --config-file nodes.config --detach > /dev/null # --start-mining $WALLET_1_ADDRESS

sleep 5s

clean_wallet_cache

# Stop wallet-rpc
killall -9 monero-wallet-rpc -q

# start wallet-rpc
_log "Running wallet-rpc 1 ... "
monero-wallet-rpc --testnet --daemon-address $NODE_IP:$NODE_1_RPC_PORT --wallet-dir $PRIVATE_TESTNET_LOCATION/ --password "" --log-level=0 --rpc-bind-port $WALLET_RPC_PORT_1 --daemon-ssl-allow-any-cert --disable-rpc-login --detach > /dev/null
_log "Running wallet-rpc 2 ... "
monero-wallet-rpc --testnet --daemon-address $NODE_IP:$NODE_1_RPC_PORT --wallet-dir $PRIVATE_TESTNET_LOCATION/ --password "" --log-level=0 --rpc-bind-port $WALLET_RPC_PORT_2 --daemon-ssl-allow-any-cert --disable-rpc-login --detach > /dev/null
_log "Running wallet-rpc 3 ... "
monero-wallet-rpc --testnet --daemon-address $NODE_IP:$NODE_1_RPC_PORT --wallet-dir $PRIVATE_TESTNET_LOCATION/ --password "" --log-level=0 --rpc-bind-port $WALLET_RPC_PORT_3 --daemon-ssl-allow-any-cert --disable-rpc-login --detach > /dev/null
sleep 10s;

# auto-refresh
curl http://127.0.0.1:$WALLET_RPC_PORT_1/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"auto_refresh","params":{"enable":true, "period":1}' -H 'Content-Type: application/json' --silent --output /dev/null
curl http://127.0.0.1:$WALLET_RPC_PORT_2/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"auto_refresh","params":{"enable":true, "period":1}' -H 'Content-Type: application/json' --silent --output /dev/null
curl http://127.0.0.1:$WALLET_RPC_PORT_3/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"auto_refresh","params":{"enable":true, "period":1}' -H 'Content-Type: application/json' --silent --output /dev/null

test_itertime=()
starttime=$(date +%s)

for i in $(seq $BENCH_ITER)
do
    clean_wallet_cache
    _log ">>>>> Iteration $i"
    iterstarttime=$(date +%s)

    # open wallet
    _log "Opening wallet 1"
    curl http://localhost:$WALLET_RPC_PORT_1/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"open_wallet","params":{"filename":"wallet_01.bin","password":""}}' -H 'Content-Type: application/json'   --silent --output /dev/null &
    _log "Opening wallet 2"
    curl http://localhost:$WALLET_RPC_PORT_2/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"open_wallet","params":{"filename":"wallet_02.bin","password":""}}' -H 'Content-Type: application/json'   --silent --output /dev/null &
    _log "Opening wallet 3"
    curl http://localhost:$WALLET_RPC_PORT_3/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"open_wallet","params":{"filename":"wallet_03.bin","password":""}}' -H 'Content-Type: application/json'   --silent --output /dev/null &
    wait
    # refresh
    _log "Refreshing wallet 1"
    curl http://localhost:$WALLET_RPC_PORT_1/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"refresh","params":{"start_height":0}}' -H 'Content-Type: application/json'   --silent --output /dev/null &
    _log "Refreshing wallet 2"
    curl http://localhost:$WALLET_RPC_PORT_2/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"refresh","params":{"start_height":0}}' -H 'Content-Type: application/json'   --silent --output /dev/null &
    _log "Refreshing wallet 3"
    curl http://localhost:$WALLET_RPC_PORT_3/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"refresh","params":{"start_height":0}}' -H 'Content-Type: application/json'   --silent --output /dev/null &
    wait
    # check balance
    _log "Checking balance 1"
    curl http://127.0.0.1:$WALLET_RPC_PORT_1/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_balance","params":{"account_index":0,"address_indices":[0,0]}}' -H 'Content-Type: application/json'   --silent --output /dev/null &
    _log "Checking balance 2"
    curl http://127.0.0.1:$WALLET_RPC_PORT_2/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_balance","params":{"account_index":0,"address_indices":[0,0]}}' -H 'Content-Type: application/json'   --silent --output /dev/null &
    _log "Checking balance 3"
    curl http://127.0.0.1:$WALLET_RPC_PORT_3/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_balance","params":{"account_index":0,"address_indices":[0,0]}}' -H 'Content-Type: application/json'   --silent --output /dev/null &
    wait
    # close wallet
    _log "Close balance 1"
    curl http://localhost:$WALLET_RPC_PORT_1/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"close_wallet"}' -H 'Content-Type: application/json'   --silent --output /dev/null &
    _log "Close balance 2"
    curl http://localhost:$WALLET_RPC_PORT_2/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"close_wallet"}' -H 'Content-Type: application/json'   --silent --output /dev/null &
    _log "Close balance 3"
    curl http://localhost:$WALLET_RPC_PORT_3/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"close_wallet"}' -H 'Content-Type: application/json'   --silent --output /dev/null &
    wait

    iterendtime=$(date +%s)
    itertime=$((iterendtime-iterstarttime))
    test_itertime+=($itertime)
done

endtime=$(date +%s)
runtime=$((endtime-starttime))
echo ">>>>> Runtime Test was " $runtime " seconds."

_log ">>>>> Each iteration runtime : "
printf '%s\n' "${test_itertime[@]}" | datamash max 1 min 1 mean 1 median 1 -H

# finish monero-wallet-rpc
killall -9 monero-wallet-rpc -q

sleep 5s
# Stop wallet-rpc
killall -9 monerod -q

# clean up monero-wallet-rpc logs
rm monero-wallet-rpc.log 2> /dev/null
rm monero-wallet-rpc.log-* 2> /dev/null
