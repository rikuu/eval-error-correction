#!/bin/bash
#
# Runs experiments for comparing results for different error correction tools
#
# Input:
# 1. Long reads
# 2. Reference genome
#

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
SCRIPTS=$DIR/scripts
MASTER=$SCRIPTS/master.sh
ANALYZE=$SCRIPTS/analyze.sh

OUTPUT=$DIR/experiments/tools

# Run
for DATASET in "ecoli" "yeast"; do
  for TOOL in "lordec" "proovread" "pbcr" "pbcr"; do
    mkdir -p $OUTPUT/$TOOL/$DATASET
    cd $OUTPUT/$TOOL/$DATASET
    $MASTER $TOOL "$1"
  done
done

# Analyze
echo -e "Size\tAligned\tError rate\tIdentity\tExpCov\tObsCov\tElapsed time\t"\
"CPU time\tMemory peak\tDisk peak\tSwap peak" | tee $OUTPUT/analysis.log
for DATASET in "ecoli" "yeast"; do
  echo -e $DATASET | tee -a $OUTPUT/analysis.log

  for TOOL in "lordec" "proovread" "pbcr" "pbcr"; do
    cd $OUTPUT/$TOOL/$DATASET
    $ANALYZE tmp/final.fasta "$1" "$2" stats.log disk.log time.log | tee -a $OUTPUT/analysis.log
  done
done
