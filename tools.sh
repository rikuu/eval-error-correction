#!/bin/bash
#
# Runs experiments for comparing results for different error correction tools
#

#
# TODO:
# - Move duplication to simple loops
#

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
source $DIR/configuration.sh

SCRIPTS=$DIR/scripts
MASTER=$SCRIPTS/master.sh
ANALYZE=$SCRIPTS/analyze.sh

OUTPUT=$OUTPUT_DIR/tools

# Define datasets
ECOLI_REF=$DIR/reads/ecoli-ref.fastq
ECOLI_LR=$DIR/reads/ecoli-lr.fastq
ECOLI_SR=$DIR/reads/ecoli-sr.fastq

YEAST_REF=$DIR/reads/yeast-ref.fastq
YEAST_LR=$DIR/reads/yeast-lr.fastq
YEAST_SR=$DIR/reads/yeast-sr.fastq

# Helper functions
run() {
  TOOL=$1
  DATASET=$2
  LONGREADS=$3
  SHORTREADS=$4

  mkdir -p $OUTPUT/$TOOL/$DATASET
  cd $OUTPUT/$TOOL/$DATASET
  $MASTER $TOOL $LONGREADS $SHORTREADS
}

analyze() {
  TOOL=$1
  DATASET=$2
  LONGREADS=$3
  REFERENCE=$4

  cd $OUTPUT/$TOOL/$DATASET
  $ANALYZE -p corrected.fasta $LONGREADS $REFERENCE stats.log disk.log time.log | tee -a $OUTPUT/analysis.log
}

# Run
run "lorma" "ecoli" $ECOLI_LR
run "pbcr-self" "ecoli" $ECOLI_LR
run "lordec" "ecoli" $ECOLI_LR $ECOLI_SR
run "proovread" "ecoli" $ECOLI_LR $ECOLI_SR
run "pbcr-illumina" "ecoli" $ECOLI_LR $ECOLI_SR

run "lorma" "yeast" $YEAST_LR
run "pbcr-self" "yeast" $YEAST_LR
run "lordec" "yeast" $YEAST_LR $YEAST_SR
run "proovread" "yeast" $YEAST_LR $YEAST_SR
run "pbcr-illumina" "yeast" $YEAST_LR $YEAST_SR

# Analyze
echo -e "Size\tAligned\tError rate\tIdentity\tExpCov\tObsCov\tElapsed time\t"\
"CPU time\tMemory peak\tDisk peak\tSwap peak" | tee $OUTPUT/analysis.log

echo -e "ecoli" | tee -a $OUTPUT/analysis.log

analyze "lorma" "ecoli" $ECOLI_LR $ECOLI_REF
analyze "pbcr-self" "ecoli" $ECOLI_LR $ECOLI_REF
analyze "lordec" "ecoli" $ECOLI_LR $ECOLI_REF
analyze "proovread" "ecoli" $ECOLI_LR $ECOLI_REF
analyze "pbcr-illumina" "ecoli" $ECOLI_LR $ECOLI_REF

echo -e "yeast" | tee -a $OUTPUT/analysis.log

analyze "lorma" "yeast" $YEAST_LR $YEAST_REF
analyze "pbcr-self" "yeast" $YEAST_LR $YEAST_REF
analyze "lordec" "yeast" $YEAST_LR $YEAST_REF
analyze "proovread" "yeast" $YEAST_LR $YEAST_REF
analyze "pbcr-illumina" "yeast" $YEAST_LR $YEAST_REF
