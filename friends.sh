#!/bin/bash
#
# Runs experiments for comparing results for different values of friends
# parameter of LoRMA
#
# Input:
# 1. Long reads
# 2. Reference genome
#

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
source $DIR/configuration.sh

SCRIPTS=$DIR/scripts
MASTER=$SCRIPTS/master.sh
ANALYZE=$SCRIPTS/analyze.sh

OUTPUT=$OUTPUT_DIR/friends

# Run
for i in 5 7 10 15 20; do
  mkdir -p $OUTPUT/$i
  cd $OUTPUT/$i
  $MASTER lorma -friends $i "$1"
done

# Analyze
echo -e "Size\tAligned\tError rate\tIdentity\tExpCov\tObsCov\tElapsed time\t"\
"CPU time\tMemory peak\tDisk peak\tSwap peak" | tee $OUTPUT/analysis.log
for i in 5 7 10 15 20; do
  cd $OUTPUT/$i
  $ANALYZE tmp/final.fasta "$1" "$2" stats.log disk.log time.log | tee -a $OUTPUT/analysis.log
done
