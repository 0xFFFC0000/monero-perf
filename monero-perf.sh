#!/bin/bash

export DNS_PUBLIC=tcp://9.9.9.9

MAIN_MONERO=""
MAIN_MONERO_CONFIG_LOCATION="~/.bitmonero/.bitmonero.conf"
TEST_MONERO=""
TEST_MONERO_CONFIG_LOCATION=""

# Number of blocks to pop
POP_BLOCKS=250

# Number of iterations
MAX_ITER=3

# Logging
LOG=""

###### U S A G E : Help and ERROR ######
function _usage() 
{
  cat <<EOF
   monero-perf-test $Options
  $*
          Usage: monero-perf-test <[options]>
          Options:
                  -m   --main_monero               Executable location of main monero. 
                  -t   --test_monero               Executable location of second monero.
                  -c   --main_monero_config_loc    Config file location for main monero. Default: ~/.bitmonero/.bitmonero.conf
                  -d   --test_monero_config_loc    Config file location for second monero.
                  -i   --iteration                 How many iteration run the benchmark.
                  -p   --pop_blocks                Number of blocks to pop.
                  -t   --help                      Show this message.
EOF
  exit 0;
}

# Log function
_log(){
    if [ "${LOG}" ]; then echo $1; fi
}

# Check result and fail
check_result(){
    return_code=$1
    error_msg=$2
    if [[ $return_code != 0 ]]; then
        echo $error_msg
        killall -9 monerod -q
        exit 1
    fi
}

while true; do
  case "$1" in
    -m | --main_monero ) MAIN_MONERO="$2"; shift 2;;
    -t | --test_monero ) TEST_MONERO="$2"; shift 2;;
    -c | --main_monero_config_loc ) MAIN_MONERO_CONFIG_LOCATION="$2"; shift 2;;
    -d | --test_monero_config_loc ) TEST_MONERO_CONFIG_LOCATION="$2"; shift 2;;
    -i | --iteration ) MAX_ITER="$2"; shift 2;;
    -p | --pop_blocks ) POP_BLOCKS="$2"; shift 2;;
    -l | --log ) LOG=1; shift 1;;
    -h | --help ) _usage; shift;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

_log "Logging is enabled"

if [ -z "${MAIN_MONERO}" ]; then
    check_result -1 "Provide main monero executable location with -m|--main_monero"
fi

if [ -z "${TEST_MONERO}" ]; then
    check_result -1 "Provide test monero executable location with -t|--test_monero"
fi

if [ -z "${TEST_MONERO_CONFIG_LOCATION}" ]; then
    check_result -1 "Provide data dir for test monero with -d|--test_monero_config_loc"
fi

# Run backgound Monero
_log  "Starting the main node..."
$MAIN_MONERO --detach --config-file=$MAIN_MONERO_CONFIG_LOCATION > /dev/null

# Wait until both monerod synced
wait_sync_monerod(){
    # Wait until monerod is synchronized
    _log  "Waiting to sync test monero..."
    while : ; do
        sleep 0.1s
        testingmonero_height=$(curl --silent http://127.0.0.1:6667/get_height -H 'Content-Type: application/json' | jq -r '.height')
        mainmonero_height=$(curl --silent http://127.0.0.1:18081/get_height -H 'Content-Type: application/json' | jq -r '.height')
        [[ $mainmonero_height != $testingmonero_height ]] || break
    done     
}

test_runtime=()
test_poptime=()
test_flushtime=()
test_synctime=()
######### Run test
for i in $(seq 1 $MAX_ITER);
do
    # Run monerod
    _log  "Starting and syncing test monero..."
    $TEST_MONERO --config-file=$TEST_MONERO_CONFIG_LOCATION  > /dev/null & 
    test_monero_pid=$!
    sleep 15s;


    # Sync both instance
    wait_sync_monerod


    # Check RPC
    _log  "Checking the RPC availability"
    curl http://127.0.0.1:6667/get_height -H 'Content-Type: application/json' --silent --output /dev/null
    check_result $? "ERROR: get_height failed for  $i iteration. If this happens in first iteration, you might need syncing both monerod offline. Then running this script."
    cyclestarttime=$(date +%s)
   

    _log  "Popping blocks..."
    starttime=$(date +%s) 
    curl http://127.0.0.1:6667/pop_blocks -d "{\"nblocks\": $POP_BLOCKS }" -H 'Content-Type: application/json' --silent --output /dev/null
    check_result $? "ERROR: pop_blocks failed for  $i iteration."
    endtime=$(date +%s)
    runtime=$((endtime-starttime))
    test_poptime+=($runtime)
    echo  ">> pop_blocks for iteration " $i " is " $runtime " seconds."
    
    
    _log  "Flushing tx pool..."
    starttime=$(date +%s) 
    curl http://127.0.0.1:6667/flush_txpool -H 'Content-Type: application/json' --silent --output /dev/null
    check_result $? "ERROR: flush_txpool failed for $i iteration."
    endtime=$(date +%s)
    runtime=$((endtime-starttime))
    test_flushtime+=($runtime)
    echo  ">> flush_txpool for iteration " $i " is " $runtime " seconds."


    # Sync both instance
    starttime=$(date +%s) 
    wait_sync_monerod
    endtime=$(date +%s)
    runtime=$((endtime-starttime))
    test_synctime+=($runtime)
    echo  ">> sync for iteration " $i " is " $runtime " seconds."
    
    
    cycleendtime=$(date +%s)
    runtime=$((cycleendtime-cyclestarttime))
    test_runtime+=($runtime)
    echo  ">> Runtime for iteration " $i " is " $runtime " seconds."

    
    _log  "Stopping the daemon..."
    curl http://127.0.0.1:6667/stop_daemon -H 'Content-Type: application/json' --silent --output /dev/null
    check_result $? "ERROR: stop_daemon failed for $i iteration."

    
    wait $test_monero_pid
    # sleep 30s
done;


echo  ">> Runtime statistics for test branch :"

echo ">> pop_blocks time : "
printf '%s\n' "${test_poptime[@]}" | datamash max 1 min 1 mean 1 median 1 -H

echo ">> flush time : "
printf '%s\n' "${test_flushtime[@]}" | datamash max 1 min 1 mean 1 median 1 -H

echo ">> sync time : "
printf '%s\n' "${test_synctime[@]}" | datamash max 1 min 1 mean 1 median 1 -H

echo ">> Complete runtime : "
printf '%s\n' "${test_runtime[@]}" | datamash max 1 min 1 mean 1 median 1 -H

# Kill the background Monero
killall -9 monerod -q
