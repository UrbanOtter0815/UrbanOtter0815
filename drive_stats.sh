#!/bin/sh
# ------------------------------------------------------------------------------
# Script:         drive_stats.sh
# Author:         sstumpf
# Date:           2024-09-25
# Last modified:  2024-11-26
# Description:    Displays drive statistics for locally mounted drives (including
#                 explicitly defined ones), network-mounted drives (AFP/SMB), 
#                 and USB drives. Depends on:
#                 $HOME/Scripts/Geektool/usage_graph.sh
# ------------------------------------------------------------------------------

# Define paths and dependencies
USAGE_GRAPH="$HOME/Scripts/Geektool/usage_graph.sh"

# Check if the dependency exists
if [ ! -x "$USAGE_GRAPH" ]; then
    echo "Error: $USAGE_GRAPH not found or not executable."
    exit 1
fi

# Display header message for drive stats
echo "\033[37mDrive stats:\033[0m"

# Explicitly check the former hardcoded drives, but don't warn if they're missing
HARDCODED_DRIVES="/dev/disk3s1s1 /dev/disk1s2s1"
for drive in $HARDCODED_DRIVES; do
    if [ -e "$drive" ]; then
        "$USAGE_GRAPH" "$drive"
    fi
done

# Call usage_graph.sh for dynamically detected local drives
for disk in $(diskutil list | awk '/Apple_APFS|Apple_HFS/ {print $1}'); do
    "$USAGE_GRAPH" "$disk"
done

# Get the output of df -h, which lists disk usage and mount points
df_output=$(df -h)

# Process the df output to filter AFP, SMB, NFS, and WebDAV network-mounted drives
echo "$df_output" | awk -v script="$USAGE_GRAPH" '
BEGIN { FS = "|" }
/afpovertcp|smbfs|_smb|\/\/|nfs|http:\/\// {
    # Extract the "Mounted from" field (1st column, typically the drive name or network path)
    system(script " " $1)
}'

# Now do the same for connected USB drives
diskutil list | grep '/dev/disk' | while read -r disk_info; do
    # Extract the disk identifier (e.g., /dev/disk2)
    disk_id=$(echo "$disk_info" | awk '{print $1}')

    # Get detailed disk info and check if it's USB
    if diskutil info "$disk_id" | grep -q "USB"; then
        "$USAGE_GRAPH" "$disk_id"
    fi
done

# Exit the script with success code 0
exit 0
