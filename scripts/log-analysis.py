#!/usr/bin/python
#
# Analyses the generated log files
#
# Input:
# 1.-3. The log files separated by commas
#

import os, sys

if len(sys.argv) < 4:
  print 'Usage: '+sys.argv[0]+' <stats.log[s]> <disk.log[s]> <time.log[s]>'+\
    '\nWhere multiple log files are separated by commas.'
  exit(1)

# Find the maximum memory and swap usages from a log file
# NOTE: CPU usage statistics are also collected and analyzed but not outputted
# for no particular reason.
def stats(stats):
  max_cpu = 0
  max_mem = 0
  max_swap = 0

  try:
    with open(stats, 'r') as f:
      for line in f:
        data = line.split(' ')
        if len(data) < 3:
          continue

        # Format CPU usage into percentages
        cpu = float(data[-3]) * 100

        # Format memory and swap usage into GB
        mem = int(data[-2]) / 1000. / 1000.
        swap = int(data[-1]) / 1000. / 1000.

        max_mem = max(max_mem, mem)
        max_cpu = max(max_cpu, cpu)
        max_swap = max(max_swap, swap)
  except IOError:
    max_mem, max_swap = '-', '-'

  return max_mem, max_swap

# Find the maximum disk usage from all log files
def disk(disk_logs):
  max_disk = 0

  try:
    for log in disk_logs.split(','):
      with open(log, 'r') as f:
        m = 0
        for line in f:
          m = max(float(line.split(' ')[-1]) / 1000, m)
        max_disk += m
  except IOError:
    max_disk = '-'

  return max_disk

# Divide seconds into either hours and minutes or minutes and seconds
# depending on whether there are enough seconds for hours
def prettyPrintTime(s):
  hours, remainder = divmod(s, 3600)
  minutes, seconds = divmod(remainder, 60)
  if hours > 0:
    return str(hours) + 'h ' + str(minutes) + 'min'
  else:
    return str(minutes) + 'min ' + str(seconds)

# Take a head of a tail of a file and cut the beginning
def tailHeadCut(file, tail, head, cut):
  stdin,stdout = os.popen2('tail -n' + str(tail) + ' ' + file + \
    ' | head -n' + str(head) + \
    ' | cut -c' + str(cut) + '-')

  stdin.close()
  lines = stdout.readlines()
  stdout.close()

  return lines[0][:-1]

# Get the sum of time spent from log files
def time(times):
  elapsed = 0
  cpu = 0
  try:
    for log in times.split(','):
      with open(log, 'r'):
        a = float(tailHeadCut(log, 21, 1, 25))
        b = float(tailHeadCut(log, 22, 1, 23))
        c = float(tailHeadCut(log, 20, 1, 31)[:-1])

        elapsed += int((a + b) / (c / 100.))
        cpu += int(a + b)
  except IOError:
    return '-', '-'

  return prettyPrintTime(elapsed), prettyPrintTime(cpu)

max_mem = 0
max_swap = 0
for log in sys.argv[1].split(','):
  mem, swap = stats(log)
  max_mem = max(mem, max_mem)
  max_swap = max(swap, max_swap)

max_disk = disk(sys.argv[2])
elapsed, cpu = time(sys.argv[3])

print elapsed+'\t'+cpu+'\t'+str(max_mem)+'\t'+str(max_disk)+'\t'+str(max_swap)+''
