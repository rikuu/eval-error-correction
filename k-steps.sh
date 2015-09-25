#!/bin/bash

dir=~/lorma
lordec_dir=~/lorma/lordec/LoRDEC-0.4.1-strict
lorma_dir=~/lorma/lorma/LoRMA-0.2/build
trimsplit=$lordec_dir/lordec-trim-split
lorma=$lorma_dir/LoRMA
time=/usr/bin/time

for i in 82 103 124; do
  mkdir tmp-$i

  bash $dir/monitor-disk.sh tmp &
  disk_pid=$!

  bash $dir/monitor-stats.sh 5 &
  stats_pid=$!

  cd tmp-$i
  $time -v $trimsplit -i ../reads-k$i.fasta -o trim.fasta &> trim-$i.log
  $time -v $lorma -threads 6 -reads trim.fasta -graph trim.fasta -output lorma-$i.fasta -discarded discarded.fasta &> correct-$i.log
  rm trim.fasta discarded.fasta

  kill $disk_pid
  kill $stats_pid

  cd ..
done

echo -e "Size\t\tAligned\t\tError rate\tIdentity\tExpCov\tObsCov\t\tElapsed time\tCPU time\tMemory peak\tDisk peak\tSwap peak"
refsize=$(du ~/lorma/ecoli/ecoli.fasta | cut -f1)

for i in 82 103 124; do
  blasr tmp-$i/lorma-$i.fasta ~/lorma/ecoli/NC_000913.fasta -sam -nproc 12 -noSplitSubreads -clipping soft -out pacbio.sam -unaligned pacbio.unaligned -bestn 1 &> blasr.log
  sam=$(python $HOME/lorma/sam-analysis.py tmp-$i/lorma-$i.fasta pacbio.sam ~/lorma/ecoli/NC_000913.fasta)
  rm pacbio.sam pacbio.unaligned blasr.log

  size=$(du tmp-$i/lorma-$i.fasta | cut -f1)
  size=$(python -c "print $size/$refsize.")
  echo -e "$size\t$sam" #\t$stats"
done
