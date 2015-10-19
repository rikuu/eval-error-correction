#!/bin/bash
#
# Runs experiments for comparing results for different error correction tools
#

#
# TODO:
# - Move duplication to simple loops
# - Split pbcr-illumina correction into parts (?)
#

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
source $DIR/configuration.sh

SCRIPTS=$DIR/scripts
MASTER=$SCRIPTS/master.sh
ANALYZE=$SCRIPTS/analyze.sh

OUTPUT=$OUTPUT_DIR/tools

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
  CORRECTED=$5

  cd $OUTPUT/$TOOL/$DATASET
  $ANALYZE -p $CORRECTED $LONGREADS $REFERENCE stats.log disk.log time.log | tee -a $OUTPUT/analysis.log
}

# Generate illumina fragment files for PBcR
mkdir -p $OUTPUT
cd $OUTPUT
$FQ2CA -libraryname illumina -technology illumina -type sanger -reads "$ECOLI_SR" > ecoli.frg
$FQ2CA -libraryname illumina -technology illumina -type sanger -reads "$YEAST_SR" > yeast.frg

# Run
run "lorma" "ecoli" $ECOLI_LR
run "pbcr-self" "ecoli" $ECOLI_LR
run "lordec" "ecoli" $ECOLI_LR $ECOLI_SR
run "proovread" "ecoli" $ECOLI_LR $ECOLI_SR
run "pbcr-illumina" "ecoli" $ECOLI_LR $OUTPUT/ecoli.frg

run "lorma" "yeast" $YEAST_LR
run "pbcr-self" "yeast" $YEAST_LR
run "lordec" "yeast" $YEAST_LR $YEAST_SR
run "proovread" "yeast" $YEAST_LR $YEAST_SR
run "pbcr-illumina" "yeast" $YEAST_LR $OUTPUT/yeast.frg

# Analyze
echo -e "Size\tAligned\tError rate\tIdentity\tExpCov\tObsCov\tElapsed time\t"\
"CPU time\tMemory peak\tDisk peak\tSwap peak" | tee $OUTPUT/analysis.log

echo -e "ecoli" | tee -a $OUTPUT/analysis.log

analyze "lorma" "ecoli" $ECOLI_LR $ECOLI_REF "corrected.fasta"
analyze "pbcr-self" "ecoli" $ECOLI_LR $ECOLI_REF "corrected.fasta"
analyze "lordec" "ecoli" $ECOLI_LR $ECOLI_REF "corrected.fasta"
analyze "lordec" "ecoli" $ECOLI_LR $ECOLI_REF "corrected-trimmed.fasta"
analyze "proovread" "ecoli" $ECOLI_LR $ECOLI_REF "corrected.fasta"
analyze "proovread" "ecoli" $ECOLI_LR $ECOLI_REF "corrected-trimmed.fasta"
analyze "pbcr-illumina" "ecoli" $ECOLI_LR $ECOLI_REF "corrected.fasta"

echo -e "yeast" | tee -a $OUTPUT/analysis.log

analyze "lorma" "yeast" $YEAST_LR $YEAST_REF "corrected.fasta"
analyze "pbcr-self" "yeast" $YEAST_LR $YEAST_REF "corrected.fasta"
analyze "lordec" "yeast" $YEAST_LR $YEAST_REF "corrected.fasta"
analyze "lordec" "yeast" $YEAST_LR $YEAST_REF "corrected-trimmed.fasta"
analyze "proovread" "yeast" $YEAST_LR $YEAST_REF "corrected.fasta"
analyze "proovread" "yeast" $YEAST_LR $YEAST_REF "corrected-trimmed.fasta"
analyze "pbcr-illumina" "yeast" $YEAST_LR $YEAST_REF "corrected.fasta"
