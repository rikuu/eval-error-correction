#!/bin/bash
#
# Runs error correction tools
#

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
SCRIPTS=$DIR/scripts

source $DIR/tools.conf
mkdir tmp

bash $SCRIPTS/monitor-disk.sh tmp &
disk_pid=$!

bash $SCRIPTS/monitor-stats.sh 5 &
stats_pid=$!

cd tmp

if [ $1 = "lorma" ]; then
  $TIME -v $dir/lorma2.sh "${@:2}" 2> ../time.log
fi

if [ $1 = "proovread" ]; then
  # Splits long reads into 20M sized chunks
  $seqchunker -s 20M -o pb-%03d.fq $2

  # Corrects each chunk separately
  for file in $(ls pb-*.fq); do
    $PROOVREAD --threads 8 -l $file --coverage $4 -s $3 --pre ${file%.fq}
  done

  # Parallelize proovread on process-level
  # parallel $proovread' --threads 4 -l {} -s '$3' --pre {.}' ::: pb-*.fq -P 4

  # Combines corrected chunks
  cat pb-*/*.trimmed.fa > trimmed.fasta
  cat pb-*/*.untrimmed.fq | awk 'NR%4==1{printf ">%s\n", substr($0,2)}NR%4==2{print}' > untrimmed.fasta
  rm -r pb*
fi

if [ $1 = "pbcr" ]; then
  $TIME -v $pbcr -l k12 -s $dir/selfSampleData/pacbio.spec -fastq $2 $3 2> ../time.log
fi

if [ $1 = "lordec" ]; then
  $TIME -v $lordec -s 3 -k 19 -i $2 -2 $3 -o lordec.fasta 2> ../correct-time.log
  $TIME -v $trimsplit -i lordec.fasta -o lordec-trimmed.fasta 2> ../trim-time.log
fi

kill $disk_pid
kill $stats_pid

cd ..
