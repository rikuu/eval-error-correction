#!/bin/bash
#
# Monitors memory and swap usage
#
# Input:
# 1. Frequency of monitoring in seconds
#

source $DIR/tools.conf

while [ "true" ]; do
  cpu=$(top -bn1 | grep load | awk '{printf "%.2f\n", $(NF-2)}')

  line=$($smem -u | tail -n1)
  swap=$(echo $line | cut -f3 -d ' ')
  mem=$(echo $line | cut -f5 -d ' ')

  echo $(date) $cpu $mem $swap >> stats.log

  sleep $1 &
  wait
done
