#!/bin/bash
#
# Runs experiments for comparing results for different sets of values for k
# in the iteration steps of LoRDEC+LoRMA
#

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
source $DIR/configuration.sh

SCRIPTS=$DIR/scripts
MASTER=$SCRIPTS/master.sh
ANALYZE=$SCRIPTS/analyze.sh

OUTPUT=$OUTPUT_DIR/k-steps

LONGREADS=$ECOLI_LR
REFERENCE=$ECOLI_REF

# Helper
run() {
  STEP=$1
  END=$2

  mkdir -p $OUTPUT/$STEP/$END
  cd $OUTPUT/$STEP/$END
  $MASTER lorma -start 19 -end $END -step $STEP "$LONGREADS"
}

analyze() {
  STEP=$1
  END=$2

  cd $OUTPUT/$STEP/$END
  $ANALYZE -p corrected.fasta "$LONGREADS" "$REFERENCE" stats.log disk.log stderr.log | tee -a $OUTPUT/analysis.log
}

# Run
run 0 19

run 3 31
run 3 46
run 3 61

run 7 33
run 7 47
run 7 61

run 14 33
run 14 47
run 14 61

run 21 40
run 21 61

# Analyze
echo -e "Size\tAligned\tError rate\tIdentity\tExpCov\tObsCov\tElapsed time\t"\
"CPU time\tMemory peak\tDisk peak\tSwap peak" | tee $OUTPUT/analysis.log

analyze 0 19

analyze 3 31
analyze 3 46
analyze 3 61

analyze 7 33
analyze 7 47
analyze 7 61

analyze 14 33
analyze 14 47
analyze 14 61

analyze 21 40
analyze 21 61
