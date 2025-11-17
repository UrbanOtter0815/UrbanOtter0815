#!/bin/bash
#
# Author  sstumpf
# Created 19-Mar-2024
# Updated 26-Mar-2024
#
# Visualize the disk usage of a given device in $1
#
# Usage:
# ======
# This script enables/disables a VPN connection to a Cisco AnyConnect server
# usage_graph <devicename>         - provide device-name
#
# |█████████—————————————————————| (total: 460Gi, free: 320Gi, 30.43% free on /dev/disk3s1)


############################################
# Functions
############################################

calculate_percentage() {
    # Function to calculate usage percentage
    #
    local total=$1
    local free=$2
    local used=$((total - free))
    local percentage=$(awk "BEGIN {printf \"%.2f\", ($used / $total) * 100}")
    echo $percentage
}

draw_graph() {
    # Function to draw a bar graph
    #
    local percentage=$1
    local width=$2
    local int=${percentage%.*} # transform 102.4 to Integer
    local bars=$(awk "BEGIN {printf \"%.0f\", $percentage * $width / 100}")
    local graph=""
    local  GREEN='\033[0;32m'
    local    RED='\033[0;31m'
    local YELLOW='\033[0;33m'
    local     NC='\033[0m' # No Color
    local progress_icon="░"
    local progress_icon="□"
    local progress_icon="█"
    # local int=67    # for testing purpose
    
    if   (( int >=  1 && int <= 33 ));     then color_code=$GREEN;
        elif (( int >= 34 && int <= 66 )); then color_code=$YELLOW;
    else
                                                color_code=$RED;
    fi

    echo -n "|" #delimit start of graph
    for ((i=0; i<$width; i++)); do
        if [ $i -lt $bars ]; then
#           printf "${GREEN}$progress_icon${NC}"
           printf "${color_code}$progress_icon${NC}"
        else
           printf "—"
        fi
    done  
    echo -n "▏" #delimit end of graph
}

############################################
# Main
############################################

#check if $1 is populated
#
if [ -z "$1" ]; then
#    echo "Failed to get disk information - exit."
    exit 1
fi

#check if device is valid
#
if ! df -h | grep -q "$1"; then
  #  echo "Device $1 is not valid or does not exist - exit."
    exit 1
fi

# Variables
#
device_name=$1
disk_info=$(df -h | grep $device_name | awk '{print $2, $4}')                                                       #including KG, MB, GB
total_gb=$(df -h | grep $device_name | awk '{print $2}')                                                            #including KG, MB, GB
free_gb=$(df -h | grep $device_name | awk '{print $4}')                                                             #including KG, MB, GB
total=$(df -k | grep $device_name | awk '{print $2}' | awk -F'[^0-9]*' '{print $1}')                                #only returns the num. value of total; use df -k as it is more accurate then df -h
free=$(df -k | grep $device_name | awk '{print $4}' | awk -F'[^0-9]*' '{print $1}')                                 #only returns the num. value of free
graph_length=20                                                                                                     #how long should the graph be?
#mount_name=$(df -h | grep $device_name | awk '{print $9}')                                                         #displays the name of the mountpoint
#mount_name=$(df -h | grep "$device_name" | awk '{$1=$2=$3=$4=$5=$6=$7=$8=""; sub(/^[ \t]+/, ""); print}')
mount_name=$(df -h | grep "$device_name" | awk '{$1=$2=$3=$4=$5=$6=$7=$8=""; sub(/^[ \t]+/, ""); sub("^/Volumes", ""); print}')

# Failed to get disk information for device
if [ -z "$total" ] || [ -z "$free" ]; then
#    echo "Failed to get disk information for device $1 - exit."
    exit 1
fi

percentage=$(calculate_percentage "$total" "$free")
draw_graph "$percentage" $graph_length
echo " (total: $total_gb, free: $free_gb, $percentage% used on $mount_name)"
exit 0
