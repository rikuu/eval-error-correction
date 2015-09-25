#!/bin/bash

dir=~/lorma
lordec_dir=$dir/lordec/LoRDEC-0.4.1-strict
#lordec_dir=$dir/lordec/LoRDEC-0.6-2

proovread=$dir/proovread/proovread/bin/proovread
seqchunker=$dir/proovread/proovread/bin/SeqChunker

pbcr=$dir/pbcr/wgs-8.3rc2/Linux-amd64/bin/PBcR

lordec=$lordec_dir/lordec-correct
trimsplit=$lordec_dir/lordec-trim-split
lorma=$dir/lorma/LoRMA-0.2/build/LoRMA

time=/usr/bin/time

mkdir tmp

bash $dir/monitor-disk.sh tmp &
disk_pid=$!

bash $dir/monitor-stats.sh 5 &
stats_pid=$!

cd tmp

if [ $1 = "lorma" ]; then
  $time -v $dir/lorma2.sh "${@:2}" 2> ../time.log
fi

if [ $1 = "ksteps" ]; then
  $time -v $trimsplit -i $2 -o trim.fasta 2> ../trim-time.log
  $time -v $lorma -friends 7 -threads 4 -reads trim.fasta -graph trim.fasta -output final.fasta -discarded discarded.fasta 2> ../lorma-time.log
fi

if [ $1 = "friends" ]; then
  $time -v $lorma -friends $3 -threads 4 -reads $2 -graph $2 -output final.fasta -discarded discarded.fasta 2> ../time.log
fi

if [ $1 = "proovread" ]; then
  $seqchunker -s 20M -o pb-%03d.fq $2

  for file in $(ls pb-*.fq); do
    $dir/proovread/proovread/bin/proovread --threads 8 -l $file --coverage $4 -s $3 --pre ${file%.fq}
  done

  # parallel $proovread' --threads 4 -l {} -s '$3' --pre {.}' ::: pb-*.fq -P 4

  cat pb-*/*.trimmed.fa > trimmed.fasta
  cat pb-*/*.untrimmed.fq | awk 'NR%4==1{printf ">%s\n", substr($0,2)}NR%4==2{print}' > untrimmed.fasta

  # rm -r pb*
fi

if [ $1 = "pbcr" ]; then
  $time -v $pbcr -l k12 -s $dir/selfSampleData/pacbio.spec -fastq $2 $3 2> ../time.log
fi

if [ $1 = "lordec" ]; then
  $time -v $lordec -s 3 -k 19 -i $2 -2 $3 -o lordec.fasta 2> ../correct-time.log
  $time -v $trimsplit -i lordec.fasta -o lordec-trimmed.fasta 2> ../trim-time.log
fi

kill $disk_pid
kill $stats_pid

cd ..
