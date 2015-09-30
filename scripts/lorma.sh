#!/bin/sh

lordec_dir=~/lorma/lordec/LoRDEC-0.4.1-strict

LORDEC=$lordec_dir/lordec-correct
TRIMSPLIT=$lordec_dir/lordec-trim-split

LORMA=~/lorma/lorma/LoRMA-0.2/build/LoRMA

start_k=19
end_k=61
k_step=7

reads=reads.fasta #$1
echo cp $1 $reads

last=$reads

k=$start_k
while [ $k -le $end_k ]; do
  reads=reads-k$k.fasta
  #echo k=$k

  echo $LORDEC -c -s 4 -k $k -i $last -2 $last -o $reads
  #rm $last

  last=$reads

  k=$(($k*2))
done

echo $TRIMSPLIT -i $reads -o trim.fasta
#rm $reads
#mv trim.fasta $reads
reads=trim.fasta

echo $LORMA -threads $threads -reads $reads -graph $reads -output final.fasta -discarded discarded.fasta
