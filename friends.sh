#!/bin/bash
#
# Runs experiments for comparing results for different values of friends
# parameter of LoRMA
#

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
source $DIR/configuration.sh

SCRIPTS=$DIR/scripts
MASTER=$SCRIPTS/master.sh
ANALYZE=$SCRIPTS/analyze.sh

OUTPUT=$OUTPUT_DIR/friends

LONGREADS=$ECOLI_LR
REFERENCE=$ECOLI_REF

VALUES="5 7 10 15 20"

# Run
for i in $VALUES; do
  mkdir -p $OUTPUT/$i
  cd $OUTPUT/$i
  $MASTER lorma -friends $i "$LONGREADS"
done

# Analyze
echo -e "Size\tAligned\tError rate\tIdentity\tExpCov\tObsCov\tElapsed time\t"\
"CPU time\tMemory peak\tDisk peak\tSwap peak" | tee $OUTPUT/analysis.log
for i in $VALUES; do
  cd $OUTPUT/$i
  $ANALYZE -p corrected.fasta "$LONGREADS" "$REFERENCE" stats.log disk.log stderr.log | tee -a $OUTPUT/analysis.log
done
