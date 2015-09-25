#!/usr/bin/python

import sys, gzip

fastafile = sys.argv[1]
output = sys.argv[2]

histogram = []

with gzip.open(fastafile) as f:
    readLen = 0
    for line in f:
        if line[0:1] != ">":
            readLen += len(line.rstrip())
        else:
            histogram.append(readLen)
            readLen = 0

sortedLst = sorted(histogram)
mid = sortedLst[2*len(sortedLst) / 3]

fo = gzip.open(output, 'w')

with gzip.open(fastafile) as f:
    index = -1
    for line in f:
        if line[0:1] == ">":
        	index += 1
        if histogram[index] >= mid:
        	fo.write(line)

fo.close()