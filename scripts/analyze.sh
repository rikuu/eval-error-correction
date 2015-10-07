#!/bin/bash
#
# Runs all the analysis on the results
#
# Input:
# 1. Input and output data in fasta format from the tested tool
# 2. The generated log files from the scripts
#

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
SCRIPTS=$DIR

source $DIR/../configuration.sh

if [[ "$#" -lt 3 ]]; then
  echo -e "$0 <out.fasta> <in.fasta> <reference> [stats.log[s] disk.log[s] time.log[s]]"
  exit 1
fi

#echo -e "Size\t\tAligned\t\tError rate\tIdentity\tExpCov\tObsCov\t\tElapsed time\tCPU time\tMemory peak\tDisk peak\tSwap peak"
REFSIZE=$(du "$2" | cut -f1)

$BLASR "$1" "$3" -sam -nproc 12 -noSplitSubreads -clipping soft -out alignment.sam -unaligned alignment.unaligned -bestn 1 &> blasr.log
SAM=$(python $SCRIPTS/sam-analysis.py "$1" alignment.sam "$3")

SIZE=$(python -c "print $(du "$1" | cut -f1)/$REFSIZE.")

if [[ "$#" -eq 6 ]]; then
  STATS=$(python $SCRIPTS/log-analysis.py "$4" "$5" "$6")
  echo -e "$SIZE\t$SAM\t$STATS"
else
  echo -e "$SIZE\t$SAM"
fi
