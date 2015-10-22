#!/bin/bash
#
# Runs experiments for comparing results for different error correction tools.
#
# NOTE: PBcR with illumina data for some unknown reason takes an unreasonable
# amount of disk space to correct the long reads, so they are split into 3
# parts and run sequentially.
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

  if [ $TOOL = "proovread" ]; then
    $TIME $MASTER $TOOL $LONGREADS $SHORTREADS 2> stderr.log 1> stdout.log
  else
    $MASTER $TOOL $LONGREADS $SHORTREADS
  fi
}

analyze() {
  TOOL=$1
  DATASET=$2
  LONGREADS=$3
  REFERENCE=$4
  CORRECTED=$5

  cd $OUTPUT/$TOOL/$DATASET
  $ANALYZE -p $CORRECTED $LONGREADS $REFERENCE stats.log disk.log stderr.log | tee -a $OUTPUT/analysis.log
}

# Generate illumina fragment files for PBcR
mkdir -p $OUTPUT
cd $OUTPUT
$FQ2CA -libraryname illumina -technology illumina -type sanger -reads "$ECOLI_SR" > ecoli.frg
$FQ2CA -libraryname illumina -technology illumina -type sanger -reads "$YEAST_SR" > yeast.frg

# Split the long reads into 3 parts
cd $OUTPUT
$SEQCHUNKER --chunk-number 3 -o ecoli-%03d.fq "$ECOLI_LR"
$SEQCHUNKER --chunk-number 3 -o yeast-%03d.fq "$YEAST_LR"

# Run
run "lorma" "ecoli" $ECOLI_LR
run "pbcr-self" "ecoli" $ECOLI_LR
run "lordec" "ecoli" $ECOLI_LR $ECOLI_SR
run "proovread" "ecoli" $ECOLI_LR $ECOLI_SR

run "pbcr-illumina" "ecoli-1" $OUTPUT/ecoli-001.fq $OUTPUT/ecoli.frg
run "pbcr-illumina" "ecoli-2" $OUTPUT/ecoli-002.fq $OUTPUT/ecoli.frg
run "pbcr-illumina" "ecoli-3" $OUTPUT/ecoli-003.fq $OUTPUT/ecoli.frg
mkdir -p $OUTPUT/pbcr-illumina/ecoli
cat $OUTPUT/pbcr-illumina/ecoli-*/corrected.fasta > $OUTPUT/pbcr-illumina/ecoli/corrected.fasta

run "lorma" "yeast" $YEAST_LR
run "pbcr-self" "yeast" $YEAST_LR
run "lordec" "yeast" $YEAST_LR $YEAST_SR
run "proovread" "yeast" $YEAST_LR $YEAST_SR

run "pbcr-illumina" "yeast-1" $OUTPUT/yeast-001.fq $OUTPUT/yeast.frg
run "pbcr-illumina" "yeast-2" $OUTPUT/yeast-002.fq $OUTPUT/yeast.frg
run "pbcr-illumina" "yeast-3" $OUTPUT/yeast-003.fq $OUTPUT/yeast.frg
mkdir -p $OUTPUT/pbcr-illumina/yeast
cat $OUTPUT/pbcr-illumina/yeast-*/corrected.fasta > $OUTPUT/pbcr-illumina/yeast/corrected.fasta

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
