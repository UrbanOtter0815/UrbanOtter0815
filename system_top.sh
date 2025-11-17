#!/bin/sh

echo "\033[37mSystem top:\033[0m"
#echo "\033[37mPROCESS            PID  %CPU %MEM\033[0m"
ps -arcwwwxo "pid pcpu pmem command" | head -7 | awk '{printf "%-8s %-6s %-6s %s\n", $1, $2, $3, $4 " " $5 " " $6 " " $7 " " $8}'
#ps -arcwwwxo "command pid %cpu %mem"  | head -12 | sed 1d
# ps -arcwwwxo "command pid %cpu %mem rss vsz"  | head -12 | sed 1d
# ps -arcwwwxo "command pid %cpu vzs"  | head -12 | sed 1d
# unformatiert:
# ps -arcwwwxo "command pid %cpu %mem vsz" | awk 'NR>1 {$5=int($5/1024)"M";}{ print;}' | head -12 | sed 1d
