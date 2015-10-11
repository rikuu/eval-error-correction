#!/bin/bash
#
# Runs experiments for comparing results for different coverages
# using LoRDEC+LoRMA and PBcR.
#
# Input:
# 1. a FASTQ file of the reads
# 2. Reference genome
#

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
source $DIR/configuration.sh

SCRIPTS=$DIR/scripts
MASTER=$SCRIPTS/master.sh
ANALYZE=$SCRIPTS/analyze.sh

OUTPUT=$OUTPUT_DIR/coverage

# Generate random subsets
mkdir -p $OUTPUT
cd $OUTPUT
python $SCRIPTS/sample-subset.py "$1"
rm tmp.*.fastq

# Run
for i in 25 50 75 100 150 175; do
  mkdir -p $OUTPUT/lorma/$i
  cd $OUTPUT/lorma/$i
  $MASTER lorma $OUTPUT/subset_"$i"x.fasta

  mkdir -p $OUTPUT/pbcr/$i
  cd $OUTPUT/pbcr/$i
  $MASTER pbcr $OUTPUT/subset_"$i"x.fastq
done

# Analyze
echo -e "Size\tAligned\tError rate\tIdentity\tExpCov\tObsCov\tElapsed time\t"\
"CPU time\tMemory peak\tDisk peak\tSwap peak" | tee $OUTPUT/analysis.log

echo -e "LoRDEC+LoRMA" | tee -a $OUTPUT/analysis.log
for i in 25 50 75 100 150 175; do
  cd $OUTPUT/lorma/$i
  $ANALYZE corrected.fasta $OUTPUT/subset_"$i"x.fasta "$2" stats.log disk.log stderr.log | tee -a $OUTPUT/analysis.log
done

echo -e "PBcR" | tee -a $OUTPUT/analysis.log
for i in 25 50 75 100 150 175; do
  cd $OUTPUT/pbcr/$i
  $ANALYZE corrected.fasta $OUTPUT/subset_"$i"x.fasta "$2" stats.log disk.log stderr.log | tee -a $OUTPUT/analysis.log
done
