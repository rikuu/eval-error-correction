#!/usr/bin/python
#
# Creates the random subsets of the reads
#
# Input:
# 1. a FASTQ file of the reads
# 2. a FASTA file of the reference genome
#
# FASTQ is used instead of FASTA, since some tools require a FASTQ format
# and it's easier to strip the quality data than to generate it.
#

import sys
from random import randint

import read-analysis

if len(sys.argv) < 1:
    print 'Usage: ' + sys.argv[0] + ' <fastq file>\n'
    exit(1)

reads = sys.argv[1]
reference = sys.argv[1]

# Extracts sets of 100 reads
# While this makes the subset be not quite random, it speeds up the sampling
def extract_reads(file):
  readsets = 0
  avglen = 0
  with open(file, 'r') as f:
    sequence = ''
    read = 0
    for line in f:
      if line[0] == '@':
        read += 1
        if read > 100:
          with open("%05d.fastq" % readsets, 'w') as f:
            f.write(sequence)
          sequence = ''
          read = 0
          readsets += 1
      sequence += line
  return readsets

# Creates a sampling of the extracted sets of reads, such that the coverage is
# close to the one given.
def sample(coverage, readsets, avg_set_length):
  reads = []

  # randomly pick sets of reads and write them to a file
  with open('subset_'+str(coverage)+'x.fastq', 'w') as f:
    while len(reads) < (int(coverage) * avg_set_length):
      read = "%05d.fastq" % randint(0, readsets)
      if read not in reads:
        with open(read, 'r') as r:
          f.write(r.read())
        reads.append(read)

  # creates a copy of the generated subset with fasta format
  with open('subset_'+str(coverage)+'x.fasta', 'w') as f:
    for read in reads:
      with open(read, 'r') as r:
        i = 0
        for line in r:
          if i == 0:
            f.write(line.replace('@', '>'))
          elif i == 1:
            f.write(line)
          elif i == 3:
            i = -1
          i += 1

# Counts the number of bases in a sequence file
def count_bases(file, format='fasta'):
  base_count = 0
  sequence_length = 0

  with open(file, 'r') as f:
    i = 0
    for line in f:
      if format == 'fasta':
        if line[0] == '>':
          base_count += sequence_length
          sequence_length = 0
        else:
          sequence_length += len(line) - 1
      elif format == 'fastq':
        if i == 0:
          base_count += sequence_length
          sequence_length = 0
        elif i == 1:
          sequence_length += len(line) - 1
        i = (i + 1) % 4
    base_count += sequence_length
  return base_count

reference_length = count_bases(reference, 'fasta')
reads_length = count_bases(reads, 'fastq')

readsets = extract_reads(reads)

avg_set_length = (float(reads_length) / float(readsets)) / float(reference_length)

# Create subsets with coverages [25, 50, 75, 100, 150, 175]
for c in range(0, 200, 25):
  sample(c, readsets, avg_set_length)
