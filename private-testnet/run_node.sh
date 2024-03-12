#!/bin/bash

source common.sh

###### U S A G E : Help and ERROR ######
function _usage()
{
  cat <<EOF
   run_node $Options
  $*
          Usage: run_node 1|2|3 --detach
          Options:
                  run one of the testnet nodes.
EOF
  exit 0;
}


if [ $# -ne 1 ]
  then
    _usage
    exit 1
fi

# Run node

case "$1" in
    "1")
        echo  "Running node 1... "
        $MONEROD --p2p-bind-port $NODE_1_P2P_PORT --rpc-bind-port $NODE_1_RPC_PORT --data-dir $PRIVATE_TESTNET_LOCATION/node_01 --p2p-bind-ip $NODE_IP --add-exclusive-node $NODE_IP:$NODE_2_P2P_PORT --add-exclusive-node $NODE_IP:$NODE_3_P2P_PORT --fixed-difficulty $DIFFICULTY --config-file nodes.config --start-mining $WALLET_1_ADDRESS
        exit 0
        ;;
    "2")
        echo  "Running node 2..."
        $MONEROD --p2p-bind-port $NODE_2_P2P_PORT --rpc-bind-port $NODE_2_RPC_PORT --data-dir $PRIVATE_TESTNET_LOCATION/node_02 --p2p-bind-ip $NODE_IP --add-exclusive-node $NODE_IP:$NODE_1_P2P_PORT --add-exclusive-node $NODE_IP:$NODE_3_P2P_PORT --fixed-difficulty $DIFFICULTY --config-file nodes.config --start-mining $WALLET_2_ADDRESS
        exit 0
        ;;
    "3")
        echo  "Running node 3..."
        $MONEROD --p2p-bind-port $NODE_3_P2P_PORT --rpc-bind-port $NODE_3_RPC_PORT --data-dir $PRIVATE_TESTNET_LOCATION/node_03 --p2p-bind-ip $NODE_IP --add-exclusive-node $NODE_IP:$NODE_1_P2P_PORT --add-exclusive-node $NODE_IP:$NODE_2_P2P_PORT --fixed-difficulty $DIFFICULTY --config-file nodes.config --start-mining $WALLET_3_ADDRESS
        exit 0
        ;;
esac