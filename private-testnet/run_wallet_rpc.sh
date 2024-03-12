#!/bin/bash

source common.sh

###### U S A G E : Help and ERROR ######
function _usage()
{
  cat <<EOF
   run_wallet_rpc $Options
  $*
          Usage: run_wallet_rpc 1|2|3
          Options:
                  run wallet_rpc. Connect to 1|2|3 node.
EOF
  exit 0;
}


if [ $# -ne 1 ]
  then
    _usage
    exit 1
fi

# Run wallet-rpc

case "$1" in
    "1")
        echo  "Running node 1..."
        $MONERO_WALLET_RPC --testnet --daemon-address $NODE_IP:$NODE_1_RPC_PORT --wallet-dir $PRIVATE_TESTNET_LOCATION/ --password "" --log-level=0 --rpc-bind-port $WALLET_RPC_PORT --daemon-ssl-allow-any-cert --disable-rpc-login
        ;;
    "2")
        echo  "Running node 2..."
        $MONERO_WALLET_RPC --testnet --daemon-address $NODE_IP:$NODE_2_RPC_PORT --wallet-dir $PRIVATE_TESTNET_LOCATION/ --password "" --log-level=2 --rpc-bind-port $WALLET_RPC_PORT --daemon-ssl-allow-any-cert --disable-rpc-login
        ;;
    "3")
        echo  "Running node 3..."
        $MONERO_WALLET_RPC --testnet --daemon-address $NODE_IP:$NODE_3_RPC_PORT --wallet-dir $PRIVATE_TESTNET_LOCATION/ --password "" --log-level=0 --rpc-bind-port $WALLET_RPC_PORT --daemon-ssl-allow-any-cert --disable-rpc-login
        ;;
esac
