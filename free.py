#!/usr/bin/python
"""
Memory Usage Summary Script
---------------------------
Author: Stephan Stumpf
Date: 2025-11-17

Description:
  This script gathers and summarizes system memory usage statistics on macOS using 
  native shell commands ('ps' and 'vm_stat'). It reports process RSS memory usage 
  and key memory statistics such as Wired, Active, Inactive, and Free memory (in MB).
  The script uses Python's subprocess module to execute and capture external commands, 
  parses their outputs, and calculates summarized metrics for system diagnostics.

Requirements:
  - Python 2.x (only, since 'print' is used as a statement)
  - macOS ('ps' and 'vm_stat' commands available)

Usage:
  Run as administrator for best results:
    python memory_summary.py

Note:
  Does not modify system state; read-only operations.
"""

import subprocess    # Used for running shell commands and capturing their output
import re            # Used for parsing output lines with regular expressions

# Get process info: total Resident Set Size (RSS) from all running processes
ps = subprocess.Popen(['ps', '-caxm', '-orss,comm'], stdout=subprocess.PIPE).communicate()[0]
vm = subprocess.Popen(['vm_stat'], stdout=subprocess.PIPE).communicate()[0]

# Split each line in process output; first line is header, skip it.
processLines = ps.split('\n')
sep = re.compile('[\s]+')   # Compiled regex for splitting by whitespace
rssTotal = 0  # Initialize total RSS memory accumulator (in kilobytes)

# Loop through each process, summing the RSS value
for row in range(1, len(processLines)):
    rowText = processLines[row].strip()           # Clean up left/right whitespace
    rowElements = sep.split(rowText)              # Split line into columns
    try:
        rss = float(rowElements[0]) * 1024        # Convert from KB to Bytes
    except:
        rss = 0                                   # Silently skip lines not containing RSS
    rssTotal += rss                               # Add to total

# Parse vm_stat output to gather detailed memory page statistics
vmLines = vm.split('\n')
sep = re.compile(':[\s]+')         # Regex to split by colon-and-whitespace
vmStats = {}                       # Dictionary for all vm_stat key/value pairs

# Each line after header (first line) and before summary (last 2 lines) contains a stat
for row in range(1, len(vmLines)-2):
    rowText = vmLines[row].strip()
    rowElements = sep.split(rowText)
    vmStats[(rowElements[0])] = int(rowElements[1].strip('\.')) * 4096  # Pages to bytes

# Print formatted memory statistics in megabytes for key categories
print 'Wired Memory:\t\t%d MB' % ( vmStats["Pages wired down"]/1024/1024 )
print 'Active Memory:\t\t%d MB' % ( vmStats["Pages active"]/1024/1024 )
print 'Inactive Memory:\t%d MB' % ( vmStats["Pages inactive"]/1024/1024 )
print 'Free Memory:\t\t%d MB' % ( vmStats["Pages free"]/1024/1024 )
print 'Real Mem Total (ps):\t%.3f MB' % ( rssTotal/1024/1024 )
