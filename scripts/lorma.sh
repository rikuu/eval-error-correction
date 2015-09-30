#!/bin/bash
#
# Runs LoRDEC iterations and LoRMA step
#

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
source $DIR/../tools.conf

usage() {
  echo "Usage: $0 [-s] [-start <19> -end <61> -step <21> -threads <6> -friends <7>] *.fasta" 1>&2
  exit 1
}

# set defaults
START_K=19
END_K=61
K_STEP=21

FRIENDS=7
THREADS=6

SAVE=0
FILE=''

while true; do
  case "$1" in
    -s)
      shift
      SAVE=1 ;;

    -start)
      shift
      case "$1" in
        *[!0-9]* | "") ;;
        *) START_K="$1"; shift ;;
      esac ;;

    -end)
      shift
      case "$1" in
        *[!0-9]* | "") ;;
        *) END_K="$1"; shift ;;
      esac ;;

    -step)
      shift
      case "$1" in
        *[!0-9]* | "") ;;
        *) K_STEP="$1"; shift ;;
      esac ;;

    -threads)
      shift
      case "$1" in
        *[!0-9]* | "") ;;
        *) THREADS="$1"; shift ;;
      esac ;;

    -friends)
      shift
      case "$1" in
        *[!0-9]* | "") ;;
        *) FRIENDS="$1"; shift ;;
      esac ;;

    -*)
      echo "$0: Unrecognized option "$1"" >&2
      usage ;;

    *)
      if [[ "$1" = '' ]]; then
        break
      fi

      if [[ $FILE = '' ]]; then
        FILE="$1"
      else
        echo "$0: Unrecognized option "$1"" >&2
        usage
      fi
      shift ;;
  esac
done

if [[ $FILE = '' ]]; then
  usage
fi

READS=$FILE
LAST=$READS

K=$START_K
while [ $K -le $END_K ]; do
  READS=reads-k"$K".fasta

  $TIME -v $LORDEC -c -s 4 -k $K -i $LAST -2 $LAST -o $READS 2> lordec-$K.log

  if [ $SAVE -eq 0 ] && [ $LAST != $FILE ]; then
    rm $LAST
    rm *.h5
  fi

  LAST=$READS

  K=$(($K+$K_STEP))
done

$TRIMSPLIT -i $READS -o trim.fasta

if [ $SAVE = 0 ]; then
  rm $READS
fi

$LORMA -friends $FRIENDS -threads $THREADS -reads trim.fasta -graph trim.fasta -output final.fasta -discarded discarded.fasta

if [ $SAVE = 0 ]; then
 rm trim.fasta
 rm discarded.fasta
fi