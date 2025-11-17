#!/bin/sh

echo "\033[37mSystem info:\033[0m"
scutil --get ComputerName;
sw_vers | awk -F':\t' '{print $2}' | paste -d ' ' - - - ;
sysctl -n hw.memsize | awk '{print $0/1073741824"GB RAM"}';
sysctl -n machdep.cpu.brand_string;
echo
echo "\033[37mSystem health:\033[0m"
top -l 1 | awk '/PhysMem/'
uptime | awk '{sub(/[0-9]|user\,|users\,|load/, "", $6); sub(/mins,|min,/, "min", $6); sub(/user\,|users\,/, "", $5); sub(",", "min", $5); sub(":", "Std ", $5); sub(/[0-9]/, "", $4); sub(/Tagen,/, " Tagen ", $4); sub(/days,/, " Tagen ", $4); sub(/mins,|min,/, "min", $4); sub(" Std ,", " Std ", $4); sub(":", "Std ", $3); sub(",", "min", $3); print "Uptime: " $3 $4 $5 $6}'
df -g | grep disk1 | awk '{print "Total /dev/disk1:",$2,"GB,", $4, "GB Free"}'
df -g | grep disk2 | awk '{print "Total /dev/disk2:",$2,"GB,", $4, "GB Free"}'

asbreg=`ioreg -rc "AppleSmartBattery"`
maxcap=`echo "${asbreg}" | awk '/MaxCapacity/{print $3}'`;
curcap=`echo "${asbreg}" | awk '/CurrentCapacity/{print $3}'`;
prcnt=`echo "scale=2; 100*$curcap/$maxcap" | bc`;
printf "Battery: %1.0f%%\n" ${prcnt};

du -sh ~/.Trash/ | awk '{print "Trash Size: " $1}'

echo
echo "\033[37mSystem top:\033[0m"
echo "\033[37m  PID PROCESS           %CPU %MEM\033[0m"
ps -arcwwwxo "pid command %cpu %mem"  | head -15 | sed 1d
