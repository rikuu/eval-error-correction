#!/bin/bash
#
# Runs experiments for comparing results for different sets of values for k
# in the iteration steps of LoRDEC+LoRMA
#
# Input:
# 1. Long reads
# 2. Reference genome
#

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
SCRIPTS=$DIR/scripts
MASTER=$SCRIPTS/master.sh
ANALYZE=$SCRIPTS/analyze.sh

OUTPUT=$DIR/experiments/k-steps

STEPS=""
ENDS=""

# Run
for i in ; do
  for j in ; do
    mkdir -p $OUTPUT/$i
    cd $OUTPUT/$i
    $MASTER lorma -start 19 -end $i -step $j "$1"
  done
done

# Analyze
echo -e "Size\tAligned\tError rate\tIdentity\tExpCov\tObsCov\tElapsed time\t"\
"CPU time\tMemory peak\tDisk peak\tSwap peak" | tee $OUTPUT/analysis.log
for i in ; do
  for j in ; do
    cd $OUTPUT/$i
    $ANALYZE tmp/final.fasta "$1" "$2" stats.log disk.log time.log | tee -a $OUTPUT/analysis.log
  done
done
