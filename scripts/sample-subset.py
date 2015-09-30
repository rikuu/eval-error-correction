#!/usr/bin/python
#
# Creates the random subsets of the reads
#
# Input:
# 1. Fastq file of the reads
#
# Fastq is used instead of fasta, since some tools require a fastq format
# and it's easier to strip the quality data than to generate it.
#

import sys
from random import randint

if len(sys.argv) < 1:
    print 'Usage: ' + sys.argv[0] + ' <fastq file>\n'
    exit(1)

reads = sys.argv[1]

# Extracts sets of 100 reads
# While this makes the subset be not quite random, it speeds up the sampling
def extract_reads(file):
  with open(file, 'r') as f:
    sequence = ''
    i = 0
    j = 0
    for line in f:
      if line[0] == '@':
        i += 1
        if i > 100:
          with open("%05d.fastq" % j, 'w') as f:
            f.write(sequence)
          sequence = ''
          i = 0
          j += 1
      sequence += line

# Creates a sampling of the extracted sets of reads, such that the coverage is
# close to the one given.
def sample(coverage):
  reads = []

  # randomly pick sets of reads and write them to a file
  with open('subset_'+str(coverage)+'x.fastq', 'w') as f:
    while len(reads) < (int(coverage) * 4.3): # TODO: Calculate these
      read = "%05d.fastq" % randint(0, 884)
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

extract_reads(reads)

# Create subsets with coverages [25, 50, 75, 100, 150, 175]
for c in range(0, 200, 25):
  sample(c)
