###############################################################################
# Disk Usage Visualization Script
#
# Description:
#   This script generates a simple console-based visualization of disk usage 
#   for all mounted filesystems, excluding certain system mounts (tmpfs, cdrom, 
#   devfs, map, disk2). It displays each disk's name and its usage as a progress 
#   bar.
#
# Usage:
#   Run the script directly in a Unix-like shell environment.
#
# Details:
#   - Temporary file /tmp/disks.lst is used for processing.
#   - Disk usage percentage is visualized using colored blocks.
#   - Variables used for processing are unset at the end for cleanup.
#
# Author: Stephan Stumpf
# Date: <2025-11-17>
###############################################################################

if [ -f /tmp/disks.lst ]
then
    rm /tmp/disks.lst
fi 

#getting disks..due to better handling with awk it creates a file
df -H | grep -vE '^Filesystem|tmpfs|cdrom|devfs|map|disk2' | awk '{ print $1 " " $5 }' >> /tmp/disks.lst

#how many disks do we have?
count=`wc -l /tmp/disks.lst|awk '{print $1}'`

for ((i=1;i <= $count;i++))
do
    currname=`awk -v i=$i 'NR==i' /tmp/disks.lst|awk '{print $1}'`
    echo "$currname   \c"
    currp=`awk -v i=$i 'NR==i' /tmp/disks.lst|awk '{print $2}'|cut -d'%' -f1`
    typeset -i a=9

    # Print a filled block (▇) for every 10% used, in white, up to used percentage
    while [ $a -lt $currp ]
    do
        echo "\033[1;37m▇\033[0m\c"
        a=`expr $a + 10`
    done

    # Print a gray block (▇) for every 10% unused up to 99%
    while [ $a -lt 99 ]
    do
        echo "\033[2;30m▇\033[0m\c"
        a=`expr $a + 10`
    done

    # Show disk usage percentage
    echo "	$currp%\c"
    echo "\r"
done

# Cleanup variables
unset count
unset i
unset currname
unset currp
unset a

