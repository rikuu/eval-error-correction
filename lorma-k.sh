#!/bin/bash
#
# Runs experiments for comparing results for different values of k
# parameter of LoRMA
#
# Input:
# 1. Long reads
# 2. Reference genome
#

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
SCRIPTS=$DIR/scripts
MASTER=$SCRIPTS/master.sh
ANALYZE=$SCRIPTS/analyze.sh

OUTPUT=$DIR/experiments/friends

# Run
for i in 19 40 61; do
  mkdir -p $OUTPUT/$i
  cd $OUTPUT/$i
  $MASTER lorma -k $i "$1"
done

# Analyze
echo -e "Size\tAligned\tError rate\tIdentity\tExpCov\tObsCov\tElapsed time\t"\
"CPU time\tMemory peak\tDisk peak\tSwap peak" | tee $OUTPUT/analysis.log
for i in 19 40 61; do
  cd $OUTPUT/$i
  $ANALYZE tmp/final.fasta "$1" "$2" stats.log disk.log time.log | tee -a $OUTPUT/analysis.log
done
