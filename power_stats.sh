#!/bin/sh
# Script Name: Power Stats
# Description: This script displays power statistics for the MacBook battery and connected Bluetooth devices.
#
# Author:   sstumpf
# Date:     26-09-2024
# Modified: 17-04-2025
#


echo "\033[37mPower stats:\033[0m"

############################################
# Functions
############################################

# Function to determine color based on percentage
draw_graph() {
    local percentage=$1
    local int=${percentage%.*} # Convert to integer if it's a decimal
    local color_code

    # Assign color based on percentage range
    if (( int >= 1 && int <= 33 )); then
        color_code='\033[0;31m'  # Red
    elif (( int >= 34 && int <= 66 )); then
        color_code='\033[0;33m'  # Yellow
    else
        color_code='\033[0;32m'  # Green
    fi

    echo -n "$color_code"
}

############################################
# MacBook Battery Status
############################################

# Extract battery percentage from pmset output and remove trailing characters
kbatt_wo_percent=$(pmset -g batt | grep ")" | awk '{print $3}' | sed 's/;//; s/%//')       # 100
color=$(draw_graph kbatt_wo_percent)

if [ ${#kbatt_wo_percent} -gt 0 ]; then 
    echo "Macbook Battery           : "$kbatt_wo_percent"%"
fi

############################################
# Bluetooth Devices Battery Status
############################################

# Iterate over connected Bluetooth devices and extract power stats
##ioreg -r -l -n AppleHSBluetoothDevice |
#while IFS= read -r line; do
#    # Extract Bluetooth Product Name from ioreg output
#    if [[ $line =~ "\"Bluetooth Product Name\"" ]]; then
#        bluetooth_product_name=$(echo "$line" | awk -F'"' '{print $4}')
#    fi
#
#    # Extract BatteryPercent and print formatted output for each device
#    if [[ $line =~ "\"BatteryPercent\"" ]]; then
#        battery_percent=$(echo "$line" | awk '{print $NF}')
#        printf "%-16s %-2s %-5s\n" "$bluetooth_product_name" ":" "$battery_percent%"
#    fi
#done


# Query Bluetooth devices via updated Sequoia-compatible service
ioreg -r -l -c AppleDeviceManagementHIDEventService -k "BatteryPercent" |
awk '
BEGIN { device_name = "N/A"; }
/"Product"/ { 
    # Extract product name (e.g., "Magic Keyboard")
    split($0, arr, "\"");
    device_name = arr[4];
}
/"BatteryPercent"/ { 
    # Extract battery percentage and print
    split($0, arr, " ");
    battery = arr[3];
    printf "%-25s : %d%%\n", device_name, battery;
    device_name = "N/A";  # Reset for next device
}'

exit 0

