#!/bin/bash

lordec_dir=~/lorma/lordec/LoRDEC-0.4.1-strict
#lordec_dir=~/lorma/lordec/LoRDEC-0.6-2
lorma_dir=~/lorma/lorma/LoRMA-0.2/build

lordec=$lordec_dir/lordec-correct
trimsplit=$lordec_dir/lordec-trim-split

lorma=$lorma_dir/LoRMA
time=/usr/bin/time

usage() {
  echo "Usage: $0 [-s] [-start <19> -end <61> -step <21> -threads <4> -friends <7>] *.fasta" 1>&2
  exit 1
}

# set defaults
start_k=19
end_k=61
k_step=21

friends=7
threads=6

save=0
file=''

while true; do
  case $1 in
    -s)
      shift
      save=1 ;;

    -start)
      shift
      case $1 in
        *[!0-9]* | "") ;;
        *) start_k=$1; shift ;;
      esac ;;

    -end)
      shift
      case $1 in
        *[!0-9]* | "") ;;
        *) end_k=$1; shift ;;
      esac ;;

    -step)
      shift
      case $1 in
        *[!0-9]* | "") ;;
        *) k_step=$1; shift ;;
      esac ;;

    -threads)
      shift
      case $1 in
        *[!0-9]* | "") ;;
        *) threads=$1; shift ;;
      esac ;;

    -friends)
      shift
      case $1 in
        *[!0-9]* | "") ;;
        *) friends=$1; shift ;;
      esac ;;

    -*)
      echo "$0: Unrecognized option $1" >&2
      usage ;;

    *)
      if [[ $1 = '' ]]; then
        break
      fi

      if [[ $file = '' ]]; then
        file=$1
      else
        echo "$0: Unrecognized option $1" >&2
        usage
      fi
      shift ;;
  esac
done

if [[ $file = '' ]]; then
  usage
fi

reads=$file
last=$reads

k=$start_k
while [ $k -le $end_k ]; do
  reads=reads-k$k.fasta

  $time -v $lordec -c -s 4 -k $k -i $last -2 $last -o $reads 2> lordec-$k.log
  #echo $(date) $k > lordecs.log

  if [ $save -eq 0 ] && [ $last != $file ]; then
    rm $last
    rm *.h5
  fi

  last=$reads

  k=$(($k+$k_step))
done

$trimsplit -i $reads -o trim.fasta

if [ $save = 0 ]; then
  rm $reads
fi

$lorma -friends $friends -threads $threads -reads trim.fasta -graph trim.fasta -output final.fasta -discarded discarded.fasta

if [ $save = 0 ]; then
 rm trim.fasta
 rm discarded.fasta
fi
