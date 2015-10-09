#!/bin/bash
#
# Runs error correction tools
#

if [[ "$#" -lt 2 ]]; then
  echo "Usage: $0 <lorma|proovread|pbcr|lordec> [lorma parameters] <long reads> [short reads]" 1>&2
  exit 1
}

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
SCRIPTS=$DIR

source $DIR/../configuration.sh

mkdir tmp

bash $SCRIPTS/monitor-disk.sh tmp &
DISK_PID=$!

bash $SCRIPTS/monitor-stats.sh 5 &
STATS_PID=$!

cd tmp

if [ "$1" = "lorma" ]; then
  $TIME -v $SCRIPTS/lorma.sh "${@:2}" 2> ../time.log

  mv final.fasta ../corrected.fasta
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
  cat pb-*/*.trimmed.fa > ../corrected-trimmed.fasta
  cat pb-*/*.untrimmed.fq | awk 'NR%4==1{printf ">%s\n", substr($0,2)}NR%4==2{print}' > ../corrected.fasta

  rm -r pb*
fi

if [ "$1" = "pbcr" ]; then
  $TIME -v $PBCR -l k12 -s $SCRIPTS/pbcr.spec -fastq "$2" "$3" 2> ../time.log

  mv k12.fasta ../corrected.fasta
fi

if [ "$1" = "lordec" ]; then
  $TIME -v $LORDEC -s 3 -k 19 -i "$2" -2 "$3" -o lordec.fasta 2> ../correct-time.log
  $TIME -v $TRIMSPLIT -i lordec.fasta -o lordec-trimmed.fasta 2> ../trim-time.log

  mv lordec.fasta ../corrected.fasta
  mv lordec-trimmed.fasta ../corrected-trimmed.fasta
fi

kill $DISK_PID
kill $STATS_PID

cd ..
