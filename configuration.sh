#!/bin/bash
#
# Sets locations for all the required tools.
#
# NOTE: This file is executed when any of the tools are required, so don't put
# any evil, destructive scripting here
#

# This is the location of the scripts
DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)

# Change this to point to where you want the results are run
OUTPUT_DIR=$DIR/experiments

# This is just a helper and is not used outside this file
TOOLS=$DIR/tools

# http://cs.helsinki.fi/u/lmsalmel/
LORMA=$TOOLS/LoRMA-0.2/build/LoRMA

# https://github.com/BioInf-Wuerzburg/proovread
PROOVREAD_DIR=$TOOLS/proovread/bin
PROOVREAD=$PROOVREAD_DIR/proovread
SEQCHUNKER=$PROOVREAD_DIR/SeqChunker

# http://wgs-assembler.sourceforge.net/wiki/index.php/PBcR
PBCR=$TOOLS/wgs-8.3rc2/Linux-amd64/bin/PBcR

# http://atgc.lirmm.fr/lordec/
LORDEC_DIR=$TOOLS/LoRDEC-0.4.1-strict
LORDEC=$LORDEC_DIR/lordec-correct
TRIMSPLIT=$LORDEC_DIR/lordec-trim-split

# https://www.selenic.com/smem/
SMEM=$TOOLS/smem-1.4/smem

# https://github.com/PacificBiosciences/blasr/
BLASR=$TOOLS/blasr/blasr

# GNU time
TIME=/usr/bin/time

# Define datasets:
#
# NOTES:
# - Sam-analysis.py reads files in fasta format only, so the reference and
# output from tools needs to be in fasta format.
#
# - All tested tools support either both fastq and fasta or just fastq format,
# so for simplicity fastq format is assumed for reads

ECOLI_REF=$DIR/reads/ecoli-ref.fasta
ECOLI_LR=$DIR/reads/ecoli-lr.fastq
ECOLI_SR=$DIR/reads/ecoli-sr.fastq

YEAST_REF=$DIR/reads/yeast-ref.fasta
YEAST_LR=$DIR/reads/yeast-lr.fastq
YEAST_SR=$DIR/reads/yeast-sr.fastq
