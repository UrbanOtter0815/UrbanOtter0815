#!/bin/bash
#
# Author  sstumpf
# Created 19-Mar-2024
# Updated 04-Oct-2024
#
# Usage:
# ======
# This script Visualize the disk usage of a given device in $1
# usage_graph.sh <devicename>         - provide device-name
# usage_graph.sh /Volumes/Backup
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

draw_graph_single_color() {
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
    local     NC='\033[0m'   # No Color
    local LIGHT-RED='\033[0;91m'
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

draw_graph() {
    # Function to draw a bar graph with specified color pattern
    local percentage=$1
    local width=$2
    local bars=$(awk "BEGIN {printf \"%.0f\", $percentage * $width / 100}")
    
    # Define colors for the pattern: GREEN, YELLOW, LIGHT-RED, RED
    local GREEN='\033[0;32m'
    local YELLOW='\033[0;33m'
    local RED='\033[0;31m'
    local MAGENTA='\033[0;35m'
    local NC='\033[0m' # No Color
    
    # Calculate thresholds for each color segment
    local green_threshold=$((width / 4))
    local yellow_threshold=$((width / 2))
    local light_red_threshold=$((3 * width / 4))
    
    echo -n "|" # Delimit start of graph
    for ((i=0; i<$width; i++)); do
        if [ $i -lt $bars ]; then
            # Determine color based on position in the bar
            if [ $i -lt $green_threshold ]; then
                printf "${GREEN}█${NC}"
            elif [ $i -lt $yellow_threshold ]; then
                printf "${YELLOW}█${NC}"
            elif [ $i -lt $light_red_threshold ]; then
                printf "${MAGENTA}█${NC}"
            else
                printf "${RED}█${NC}"
            fi
        else
            printf "—"
        fi
    done  
    echo -n "▏" # Delimit end of graph
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
#percentage=100   # for testing purposes
draw_graph "$percentage" $graph_length
echo " (total: $total_gb, free: $free_gb, $percentage% used on $mount_name)"
exit 0
