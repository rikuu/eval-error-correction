#!/bin/bash
#
# Runs experiments for comparing results for different coverages
# using LoRDEC+LoRMA and PBcR.
#
# Input:
# 1. Location of read subsets
# 2. Reference genome

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
MASTER=$DIR/master.sh
ANALYZE=$DIR/analyze.sh

# Run
for i in 25 50 75 100 150 175; do
  mkdir $DIR/experiments/coverage/lorma/$i
  cd $DIR/experiments/coverage/lorma/$i
  $MASTER lorma $1/subset-$i.fasta

  mkdir $DIR/experiments/coverage/pbcr/$i
  cd $DIR/experiments/coverage/pbcr/$i
  $MASTER pbcr $1/subset-$i.fastq
done

# Analyze
echo -e "Size\tAligned\tError rate\tIdentity\tExpCov\tObsCov\tElapsed time\tCPU time\tMemory peak\tDisk peak\tSwap peak"

echo -e "LoRDEC+LoRMA"
for i in 25 50 75 100 150 175; do
  cd $DIR/experiments/coverage/lorma/$i
  $ANALYZE tmp/final.fasta $1/subset-$i.fasta $2 stats.log disk.log time.log
done

echo -e "PBcR"
for i in 25 50 75 100 150 175; do
  cd $DIR/experiments/coverage/pbcr/$i
  $ANALYZE tmp/k12.fasta $1/subset-$i.fasta $2 stats.log disk.log time.log
done
