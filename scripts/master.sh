#!/bin/bash
#
# Runs error correction tools
#

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
SCRIPTS=$DIR/scripts

source $DIR/../configuration.sh

mkdir tmp

bash $SCRIPTS/monitor-disk.sh tmp &
DISK_PID=$!

bash $SCRIPTS/monitor-stats.sh 5 &
STATS_PID=$!

cd tmp

if [ "$1" = "lorma" ]; then
  $TIME -v $SCRIPTS/lorma2.sh "${@:2}" 2> ../time.log
fi

if [ "$1" = "proovread" ]; then
  # Splits long reads into 20M sized chunks
  $SEQCHUNKER -s 20M -o pb-%03d.fq "$2"

  # Corrects each chunk separately
  for FILE in $(ls pb-*.fq); do
    $PROOVREAD --threads 8 -l $FILE --coverage "$4" -s "$3" --pre "${FILE%.fq}"
  done

  # Parallelize proovread on process-level
  # parallel $proovread' --threads 4 -l {} -s '$3' --pre {.}' ::: pb-*.fq -P 4

  # Combines corrected chunks
  cat pb-*/*.trimmed.fa > trimmed.fasta
  cat pb-*/*.untrimmed.fq | awk 'NR%4==1{printf ">%s\n", substr($0,2)}NR%4==2{print}' > untrimmed.fasta
  rm -r pb*
fi

if [ "$1" = "pbcr" ]; then
  $TIME -v $PBCR -l k12 -s $DIR/selfSampleData/pacbio.spec -fastq "$2" "$3" 2> ../time.log
fi

if [ "$1" = "lordec" ]; then
  $TIME -v $LORDEC -s 3 -k 19 -i "$2" -2 "$3" -o lordec.fasta 2> ../correct-time.log
  $TIME -v $TRIMSPLIT -i lordec.fasta -o lordec-trimmed.fasta 2> ../trim-time.log
fi

kill $DISK_PID
kill $STATS_PID

cd ..
