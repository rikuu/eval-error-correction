#!/bin/bash
#
# Monitors disk usage
#

while [ "true" ]; do
  while inotifywait -r -e modify -e create -e delete $1 &> /dev/null; do
    size=$(du -ms "$1" | cut -f1)
    echo $(date) $size >> disk.log
  done
done
