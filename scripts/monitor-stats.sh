#!/bin/bash
#
# Monitors memory and swap usage
#
# Input:
# 1. Frequency of monitoring in seconds
#

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
source $DIR/../configuration.sh

while [ "true" ]; do
  CPU=$(top -bn1 | grep load | awk '{printf "%.2f\n", $(NF-2)}')

  LINE=$($SMEM -u | tail -n1)
  SWAP=$(echo $LINE | cut -f3 -d ' ')
  MEM=$(echo $LINE | cut -f5 -d ' ')

  echo $(date) $CPU $MEM $SWAP >> stats.log

  sleep $1 &
  wait
done
