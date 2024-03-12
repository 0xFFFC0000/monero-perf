#!/bin/bash

source common.sh

###### U S A G E : Help and ERROR ######
function _usage()
{
  cat <<EOF
   open_wallet $Options
  $*
          Usage: open_wallet 1|2|3
          Options:
                  open one of the wallets.
EOF
  exit 0;
}


if [ $# -ne 1 ]
  then
    _usage
    exit 1
fi

# Open wallet

case "$1" in
    "1")
        echo  "opening wallet 1..."
        $MONERO_WALLET_CLI --restore-height 0 --testnet --daemon-port $NODE_1_RPC_PORT --trusted-daemon --wallet-file $PRIVATE_TESTNET_LOCATION/wallet_01.bin --password '' --log-file $PRIVATE_TESTNET_LOCATION/wallet_01.log
        ;;
    "2")
        echo  "opening wallet 2..."
        $MONERO_WALLET_CLI --restore-height 0 --testnet --daemon-port $NODE_2_RPC_PORT --trusted-daemon --wallet-file $PRIVATE_TESTNET_LOCATION/wallet_02.bin --password '' --log-file $PRIVATE_TESTNET_LOCATION/wallet_02.log
        ;;
    "3")
        echo  "opening wallet 3..."
        $MONERO_WALLET_CLI --restore-height 0 --testnet --daemon-port $NODE_3_RPC_PORT --trusted-daemon --wallet-file $PRIVATE_TESTNET_LOCATION/wallet_03.bin --password '' --log-file $PRIVATE_TESTNET_LOCATION/wallet_03.log
        ;;
esac


