#!/bin/bash

peak=0

trap save_peak EXIT
function save_peak() {
  echo $peak > peak_disk.log
  exit 1
}

while [ "true" ]; do
  while inotifywait -r -e modify -e create -e delete $1 &> /dev/null; do
    size=$(du -ms "$1" | cut -f1)
    echo $(date) $size >> disk.log

    if [ "$peak" -lt "$size" ]; then
      peak=$size
    fi
  done
done

