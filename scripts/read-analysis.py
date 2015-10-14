#!/usr/bin/python
#
# Analyzes the long and short reads.
# Supports FASTA and FASTQ formats and reading gzipped files.
#
# Input:
# 1. Reads
# 2. Reference genome
#

import sys, gzip

if len(sys.argv) < 3:
  print 'Usage: ' + sys.argv[0] + ' <reads> <reference>'
  exit(1)

readsFile = sys.argv[1]
referenceFile = sys.argv[2]

def count_stats(filename, format='fasta', gzipped=False):
  n_count = 0
  base_count = 0
  max_base = 0
  sequence_count = 0
  sequence_length = 0

  file = open(filename, 'r') if not gzipped else gzip.open(filename, 'rb')

  i = 0
  for line in file:
    if format == 'fasta':
      if line[0] == '>':
        sequence_count += 1
        base_count += sequence_length
        max_base = max(sequence_length, max_base)
        sequence_length = 0
      else:
        sequence_length += len(line) - 1
    elif format == 'fastq':
      if i == 0:
        sequence_count += 1
        base_count += sequence_length
        max_base = max(sequence_length, max_base)
        sequence_length = 0
      elif i == 1:
        sequence_length += len(line) - 1
      i = (i + 1) % 4

  sequence_count += 1
  base_count += sequence_length
  max_base = max(sequence_length, max_base)
  sequence_length = 0

  file.close()

  return base_count, max_base, n_count, sequence_count

def print_ratio_stat(stat, a, b):
  try:
    print stat + ': ' + str(float(a) / float(b)) + \
      ' ( ' + str(a) + '/' + str(b) + ' )'
  except ZeroDivisionError:
    print stat + ': ( ' + str(a) + '/' + str(b) + ' )'

reference_base_count, reference_max_base, reference_n_count, reference_sequence_count = count_stats(referenceFile)
reads_base_count, reads_max_base, reads_n_count, reads_sequence_count = count_stats(readsFile)

print_ratio_stat('Coverage', reads_base_count, reference_base_count)

print 'Reads: ' + str(reads_sequence_count)
print 'Max. read length: ' + str(reads_max_base)
print_ratio_stat('Avg. read length', reads_base_count, reads_sequence_count)

print_ratio_stat('Reads N rate', reads_n_count, reads_base_count)
print_ratio_stat('Reference N rate', reference_n_count, reference_base_count)
