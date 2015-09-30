#!/usr/bin/python
#
# Creates the random subsets of the reads
#

import sys
from random import randint

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

def sample(coverage):
  reads = []
  with open('subset_'+str(coverage)+'x.fastq', 'w') as f:
    while len(reads) < (int(coverage) * 4.3):
      read = "%05d.fastq" % randint(0, 884)
      if read not in reads:
        with open(read, 'r') as r:
          f.write(r.read())
        reads.append(read)

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

reads = sys.argv[1]
extract_reads(reads)
for c in range(0, 200, 25):
  sample(c)
