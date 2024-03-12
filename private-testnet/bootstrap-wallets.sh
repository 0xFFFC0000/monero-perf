#!/bin/bash

source common.sh

# Create 3 wallets

$MONERO_WALLET_CLI --testnet --generate-new-wallet $PRIVATE_TESTNET_LOCATION/wallet_01.bin  --restore-deterministic-wallet --electrum-seed="sequence atlas unveil summon pebbles tuesday beer rudely snake rockets different fuselage woven tagged bested dented vegan hover rapid fawns obvious muppet randomly seasons randomly" --password "" --log-file $PRIVATE_TESTNET_LOCATION/wallet_01.log

$MONERO_WALLET_CLI --testnet --generate-new-wallet $PRIVATE_TESTNET_LOCATION/wallet_02.bin  --restore-deterministic-wallet --electrum-seed="deftly large tirade gumball android leech sidekick opened iguana voice gels focus poaching itches network espionage much jailed vaults winter oatmeal eleven science siren winter" --password "" --log-file $PRIVATE_TESTNET_LOCATION/wallet_02.log

$MONERO_WALLET_CLI --testnet --generate-new-wallet $PRIVATE_TESTNET_LOCATION/wallet_03.bin  --restore-deterministic-wallet --electrum-seed="upstairs arsenic adjust emulate karate efficient demonstrate weekday kangaroo yoga huts seventh goes heron sleepless fungal tweezers zigzags maps hedgehog hoax foyer jury knife karate" --password "" --log-file $PRIVATE_TESTNET_LOCATION/wallet_03.log