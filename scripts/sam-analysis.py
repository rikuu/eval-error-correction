#!/usr/bin/python
#
# Read a SAM alignment file and compute alignment statistics.
#
# Input: 1. Fasta file of reads
#        2. SAM file which must include CIGAR strings. Use
#           soft clipping to get accurate proportional statistics.
#        3. Fasta file containing reference sequence(s)
#
# Output: Size of aligned regions (and proportion)
#         Error rate of aligned regions

import sys, re, gzip

if len(sys.argv) < 4:
    print 'Usage: ' + sys.argv[0] + ' <fasta file> <sam file> <reference fasta file> [<uncovered parts fasta>]]\n'
    exit(1)

genome = dict()
coverage = dict()

fastafile=sys.argv[1]
samfile=sys.argv[2]
reffile=sys.argv[3]
uncoveredfile=None

if len(sys.argv) > 4:
    uncoveredfile = sys.argv[4]

# Load the reference genome
name = ''
seq = ''

with open(reffile) as f:
# with gzip.open(reffile) as f:
    for line in f:
        line = line.rstrip()
        if line[0:1] == '>':
            if seq != '':
                genome[name] = seq
                coverage[name] = [0] * len(seq)
            fields = line.split()
            name = fields[0][1:]
            seq = ''
        else:
            seq = seq + line

if seq != '':
    genome[name] = seq
    coverage[name] = [0] * len(seq)

# count the number of bases in reads and the expected coverage of the genome
totalReadLength=0
expCoverage=1.0
genomeLen=0.0

for chrom in genome.keys():
    genomeLen += float(len(genome[chrom]))

with open(fastafile) as f:
# with gzip.open(fastafile) as f:
    #readLen = 0.0
    for line in f:
        line = line.rstrip()
        if line[0:1] != ">":
            totalReadLength += len(line)
            #readLen += len(line)
        #else:
            #expCoverage *= (1.0-float(readLen)/float(genomeLen))
            #readLen = 0.0
#expCoverage *= (1.0-float(readLen)/float(genomeLen))

#print 'Expected coverage: ' + str(1.0-expCoverage) + '\n'

errors=0
alignedRegionRead=0
alignedRegionGenome=0
matchingBases=0

expCoverage=1.0

with open(samfile) as f:
    for line in f:
        if line[0:1] == '@':
            continue
        cols = line.split('\t')
        refname = cols[2]
        if refname == "*":
            continue
        gseq = genome[refname]
        rseq = cols[9]
        gpos = int(cols[3])-1
        rpos = 0;

        cigar = cols[5]
        letters = re.split('[0-9]*', cigar)
        counts = re.split('[MIDNSHP=X]', cigar)
        letters = letters[1:]

        alignedRegionThisRead = 0

        for i in range(0, len(letters)):
            op = letters[i]
            c = int(counts[i])
            if op == 'M':
                for j in range(0, c):
                    if gseq[gpos+j] != rseq[rpos+j]:
                        errors += 1
                    else:
                        matchingBases += 1
                gpos += c
                rpos += c
                alignedRegionRead += c
                alignedRegionThisRead += c
                alignedRegionGenome += c
            elif op == 'I':
                errors += c
                rpos += c
                alignedRegionThisRead += c
                alignedRegionRead += c
            elif op == 'D':
                errors += c
                gpos += c
                alignedRegionGenome += c
            elif op == 'S':
                rpos += c
            elif op == 'H':
                rpos += 0
            else:
                print 'Unhandled CIGAR Op: ' + op + '\n'

        expCoverage *= (1.0-float(alignedRegionThisRead)/float(genomeLen))

        covArray = coverage[refname]
        for i in range(int(cols[3])-1, gpos):
            covArray[i] += 1

expectedCoverage = str(1.0 - expCoverage)
#print 'Expected coverage: ' + str(1.0-expCoverage) + '\n'

genomeLen=0
coveredLen=0
for name in coverage.keys():
    covArray = coverage[name]
    gseq = genome[name]
    for i in range(0, len(covArray)):
        if gseq[i] != 'N' and gseq[i] != 'n':
            genomeLen += 1
            if covArray[i] > 0:
                coveredLen += 1

aligned = str(float(alignedRegionRead) / float(totalReadLength))
identity = str(float(matchingBases) / float(alignedRegionGenome))
observedCoverage = str(float(coveredLen) / float(genomeLen))
errorRate = str(float(errors)/float(alignedRegionGenome))

print aligned + '\t' + errorRate + '\t' + identity + '\t' + expectedCoverage + '\t' + observedCoverage

# print 'Size of aligned regions / Length of reads: ' + str(alignedRegionRead) + '/' + str(totalReadLength) + ' (' + str(float(alignedRegionRead)/float(totalReadLength)) + ')\n'
# print 'Error rate of aligned regions: ' + str(errors) + '/' + str(alignedRegionGenome) + ' (' + str(float(errors)/float(alignedRegionGenome)) + ')\n'
# print 'Identity of aligned regions: ' + str(matchingBases) + '/' + str(alignedRegionGenome) + ' (' + str(float(matchingBases)/float(alignedRegionGenome)) + ')\n'
# print 'Coverage of genome: ' + str(coveredLen) + '/' + str(genomeLen) + ' (' + str(float(coveredLen)/float(genomeLen)) + ')\n'

if uncoveredfile != None:
    f = open(uncoveredfile, 'w')
    for name in coverage.keys():
        covArray = coverage[name]
        gseq = genome[name]
        start = -1
        end = -1
        for i in range(0, len(covArray)):
            if gseq[i] != 'N' and gseq[i] != 'n' and covArray[i] == 0:
                if start < 0:
                    start = i
                end = i
            else:
                if start >= 0:
                    if start >= 5:
                        start -= 5
                    else:
                        start = 0
                    if end < len(gseq)-5:
                        end += 5
                    else:
                        end = len(gseq)-1
                    f.write('>' + name + '_' + str(len(gseq)) + '_' + str(start) + '_' + str(end) + '\n')
                    f.write(gseq[start:end+1] + '\n')
                start = -1
        if start >= 0:
            f.write('>' + name + '_' + str(len(gseq)) + '_' + str(start) + '_' + str(end) + '\n')
            f.write(gseq[start:end+1] + '\n')
    f.close()
