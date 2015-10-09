#!/bin/bash
#
# Monitors disk usage
#
# Input:
# 1. Folder to monitor
#

while [ "true" ]; do

  # Waits for events from the kernel
  while inotifywait -r -e modify -e create -e delete "$1" &> /dev/null; do
    SIZE=$(du -ms "$1" | cut -f1)
    echo $(date) $SIZE >> disk.log
  done
done
