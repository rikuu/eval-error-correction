#!/usr/bin/python
#
# Analyzes the long and short reads
#
# Input:
# 1. A FASTA file of the reads
# 2. A FASTA file of the reference genome
#

import sys, gzip

if len(sys.argv) < 3:
  print 'Usage: ' + sys.argv[0] + ' <reads> <reference>'
  exit(1)

readsFile = sys.argv[1]
referenceFile = sys.argv[2]

# This is a definititely over-engineered implementation
class Counter:
  def __init__(self):
    self.n_count = 0
    self.base_count = 0
    self.max_base = 0
    self.sequence_count = 0
    self.sequence_length = 0

  def parse_line(self, line):
    if line[0] == '>':
      self.sequence_count += 1
      self.base_count += self.sequence_length
      self.max_base = max(self.sequence_length, self.max_base)
      self.sequence_length = 0
    else:
      self.sequence_length += len(line) - 1

      for m in line:
        if m in ['N', 'n']:
          self.n_count += 1

  def read(self, file):
    if file.endswith('.gz'):
      with gzip.open(file, 'rb') as f:
        for line in f:
          self.parse_line(line)
          self.base_count += self.sequence_length
    else:
      with open(file, 'r') as f:
        for line in f:
          self.parse_line(line)
          self.base_count += self.sequence_length

    return self.base_count, self.max_base, self.n_count, self.sequence_count

def print_ratio_stat(stat, a, b):
  try:
    print stat + ': ' + str(float(a) / float(b)) + \
      ' ( ' + str(a) + '/' + str(b) + ' )'
  except ZeroDivisionError:
    print stat + ': ( ' + str(a) + '/' + str(b) + ' )'

def count_stats(file):
  counter = Counter()
  return counter.read(file)

reference_base_count, reference_max_base, reference_n_count, reference_sequence_count = count_stats(referenceFile)
reads_base_count, reads_max_base, reads_n_count, reads_sequence_count = count_stats(readsFile)

print_ratio_stat('Coverage', reads_base_count, reference_base_count)

print 'Reads: ' + str(reads_sequence_count)
print 'Max read: ' + str(reads_max_base)
print_ratio_stat('Avg read', reads_base_count, reads_sequence_count)

print_ratio_stat('Reads N rate', reads_n_count, reads_base_count)
print_ratio_stat('Reference N rate', reference_n_count, reference_base_count)
