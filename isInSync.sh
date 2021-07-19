#!/bin/bash
# Get the timestamp of the current head block and compare it to the current timestamp of the system
# If the timestamp of the head block is more than 10 seconds behind, the node is considered out of sync
MAX_DIFF=10
HEAD_BLOCK_ISO_TIME="$(curl -s 'http://localhost:8888/v1/chain/get_info' | jq -r '.head_block_time')Z"
HEAD_BLOCK_EPOCH=$(date -d$HEAD_BLOCK_ISO_TIME +%s)
sleep 0.5
LOCAL_EPOCH=$(date +%s)

re='^[0-9]+$'
if ! [[ $HEAD_BLOCK_EPOCH =~ $re ]] ; then
   echo "error: Not a number" >&2; exit 1
fi

TIME_DIFF=`expr $LOCAL_EPOCH - $HEAD_BLOCK_EPOCH`

if [ $TIME_DIFF -gt $MAX_DIFF ] ; then
  echo "error: Not in sync" >&2; exit 1
fi

exit 0