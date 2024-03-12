#!/bin/bash

source common.sh

if [ -e "$PRIVATE_TESTNET_LOCATION" ];
then
    rm -rf $PRIVATE_TESTNET_LOCATION
    mkdir $PRIVATE_TESTNET_LOCATION
else
    echo "$PRIVATE_TESTNET_LOCATION does not exist."
    exit 1
fi