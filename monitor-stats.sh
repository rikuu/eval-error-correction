#!/bin/bash

smem=$HOME/lorma/smem-1.4/smem

while [ "true" ]; do
  cpu=$(top -bn1 | grep load | awk '{printf "%.2f\n", $(NF-2)}')
  #mem=$(free -m | head -n2 | tail -n1 | cut -c 24-31)
  #swap=$(free -m | tail -n1 | cut -c 24-31)

  line=$($smem -u | tail -n1)
  swap=$(echo $line | cut -f3 -d ' ')
  mem=$(echo $line | cut -f5 -d ' ')

  echo $(date) $cpu $mem $swap >> stats.log

  sleep $1 &
  wait
done
