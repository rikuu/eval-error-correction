#!/usr/bin/python

import sys
from random import randint

def random_sequence(file, sequence_count):
  sequence_i = randint(0, sequence_count)
  with open(file, 'r') as f:
    sequence = ''
    length = 0

    i = -1
    for line in f:
      if line[0] == '>':
        i += 1
        if i > sequence_i:
          return sequence, length

      if i == sequence_i:
        sequence += line

        if line[0] != '>':
          length += len(line) - 1

def count_stats(file):
  n_count = 0
  base_count = 0
  max_base = 0
  sequence_count = 0

  with open(file, 'r') as f:
    sequence_length = 0

    for line in f:
      if line[0] == '>':
        sequence_count += 1
        base_count += sequence_length

        if sequence_length > max_base:
          max_base = sequence_length

        sequence_length = 0
      else:
        sequence_length += len(line) - 1

        for m in line:
          if m in ['N', 'n']:
            n_count += 1

    base_count += sequence_length

  return base_count, max_base, n_count, sequence_count

def sample_subset(readsFile, coverage):
  reference_base_count, reference_max_base, reference_n_count, reference_sequence_count = count_stats(referenceFile)
  reads_base_count, reads_max_base, reads_n_count, reads_sequence_count = count_stats(readsFile)

  with open('subset_'+str(coverage)+'x.fasta', 'w') as f:
    length = 0
    c = 0
    while c < coverage:
      sequence, l = random_sequence(readsFile, reads_sequence_count)
      length += l
      c = length / reference_base_count

      print str((c / coverage) * 100) + '% ( ' + str(c) + ' / ' + str(coverage) + ' )'

      f.write(sequence)

#readsFile = sys.argv[1]
#referenceFile = sys.argv[2]
#coverage = sys.argv[3]

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

#extract_reads(sys.argv[1])

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

for c in range(0, 200, 25):
  sample(c)

#print count_stats(sys.argv[1])