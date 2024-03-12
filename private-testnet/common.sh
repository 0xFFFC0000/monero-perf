#!/bin/bash

if [[ ! $PRIVATE_TESTNET_LOCATION ]];
then
  echo "PRIVATE_TESTNET_LOCATION variable is not defined."
  export PRIVATE_TESTNET_LOCATION=$HOME/PRIVATE_TESTNET
fi

if [[ ! $BIN_DIR ]];
then
  echo "BIN_DIR variable is not defined."
  export MONEROD=$(which monerod)
  export MONERO_WALLET_CLI=$(which monero-wallet-cli)
  export MONERO_WALLET_RPC=$(which monero-wallet-rpc)

  if [ -z "${MONEROD}" ] || [ -z "${MONERO_WALLET_CLI}" ] || [ -z "${MONERO_WALLET_RPC}" ];
  then
    echo "Unable to find executables correctly."
    echo "monerod : $MONEROD"
    echo "monero-wallet-cli : $MONERO_WALLET_CLI"
    echo "monero-wallet-rpc : $MONERO_WALLET_RPC"
    echo "Error."
    exit 1
  fi
else
  export MONEROD=$BIN_DIR/monerod
  export MONERO_WALLET_CLI=$BIN_DIR/monero-wallet-cli
  export MONERO_WALLET_RPC=$BIN_DIR/monero-wallet-rpc
fi

export DNS_PUBLIC=tcp://9.9.9.9

# Log function
_log(){
    if [ "${LOG}" ];
    then
        echo $1
    fi
}

_sync_all_nodes(){
  cp $PRIVATE_TESTNET_LOCATION/node_03/testnet/lmdb $PRIVATE_TESTNET_LOCATION/node_02/testnet/ -rf
  cp $PRIVATE_TESTNET_LOCATION/node_03/testnet/lmdb $PRIVATE_TESTNET_LOCATION/node_01/testnet/ -rf
}

# Start nodes

NODE_IP=127.0.0.1

NODE_1_P2P_PORT=28080
NODE_2_P2P_PORT=38080
NODE_3_P2P_PORT=48080

NODE_1_RPC_PORT=28081
NODE_2_RPC_PORT=38081
NODE_3_RPC_PORT=48081

DIFFICULTY=100

WALLET_RPC_PORT=28082
WALLET_RPC_PORT_1=28083
WALLET_RPC_PORT_2=28084
WALLET_RPC_PORT_3=28085

BENCH_ITER=5

WALLET_1_ADDRESS=9wviCeWe2D8XS82k2ovp5EUYLzBt9pYNW2LXUFsZiv8S3Mt21FZ5qQaAroko1enzw3eGr9qC7X1D7Geoo2RrAotYPwq9Gm8
WALLET_2_ADDRESS=9wq792k9sxVZiLn66S3Qzv8QfmtcwkdXgM5cWGsXAPxoQeMQ79md51PLPCijvzk1iHbuHi91pws5B7iajTX9KTtJ4bh2tCh
WALLET_3_ADDRESS=9wviCeWe2D8XS82k2ovp5EUYLzBt9pYNW2LXUFsZiv8S3Mt21FZ5qQaAroko1enzw3eGr9qC7X1D7Geoo2RrAotYPwq9Gm8

MINER_THREADS=12