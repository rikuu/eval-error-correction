#!/bin/bash

dir=~/lorma
lorma=~/lorma/lorma2.sh
time=/usr/bin/time

for i in 5 7 10 15 20; do
  mkdir $i
  cd $i

  mkdir tmp

  bash $dir/monitor-disk.sh tmp &
  disk_pid=$!

  bash $dir/monitor-stats.sh 5 &
  stats_pid=$!

  cd tmp

  $time -v $lorma -friends $i -threads 6 -step 21 -start 19 -end 61 $1 &> ../time.log

  cd ../..

  kill $disk_pid
  kill $stats_pid
done

echo -e "Size\t\tAligned\t\tError rate\tIdentity\tExpCov\tObsCov\t\tElapsed time\tCPU time\tMemory peak\tDisk peak\tSwap peak"
refsize=$(du $1 | cut -f1)

for i in 5 7 10 15 20; do
  blasr $i/tmp/final.fasta ~/lorma/ecoli/NC_000913.fasta -sam -nproc 12 -noSplitSubreads -clipping soft -out pacbio.sam -unaligned pacbio.unaligned -bestn 1 &> blasr.log
  sam=$(python $HOME/lorma/sam-analysis.py $i/tmp/final.fasta pacbio.sam ~/lorma/ecoli/NC_000913.fasta)
  rm pacbio.sam pacbio.unaligned blasr.log

  size=$(du $i/tmp/final.fasta | cut -f1)
  size=$(python -c "print $size/$refsize.")

  stats=$(python ~/lorma/log-analysis.py $i/stats.log $i/disk.log $i/time.log)
  echo -e "$size\t$sam\t$stats"
done
