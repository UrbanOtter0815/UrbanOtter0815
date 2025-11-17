#!/bin/sh

###############################################################################
# Script Name: active_network_device_info.sh
# Description: Identifies the active network device on a macOS system,
#              fetches its MAC address, and lists network devices available
#              via ARP associated with the active device.
#
# Usage:      Run the script without arguments. Requires 'networksetup', 'ifconfig', and 'arp'.
# Author:     Stephan Stumpf
# Last Modified:    2025-11-17
# Platform:   Tested on macOS (Darwin)
###############################################################################

# Initialize variables for the device name and MAC address
active_device=""
active_device_mac=""

# Loop through all network devices listed by networksetup
for device in $(networksetup -listallhardwareports | awk '/Device/{print $2}'); do
    # Obtain interface output for a given device, redirecting errors to /dev/null
    ifout=$(ifconfig "$device" 2>/dev/null)
    # Check if the device is active by searching for 'status: active' in the output
    if echo "$ifout" | grep -q 'status: active'; then
        active_device="$device"  # Store the active device name
        # Extract the MAC address (ether field) from the active device's output
        active_device_mac=$(echo "$ifout" | awk '/ether/{print $2}')
        break  # Stop looping once the first active device is found
    fi
done

# If no active device is found, print an error and exit
if [ -z "$active_device" ]; then
    echo "No active network device found."
    exit 1
fi

# Print message about the active network device in white text (ANSI codes)
echo "\033[37mAvailable network devices on $active_device:\033[0m";
# Use arp -a to list all ARP entries, filter by active device, and format output
arp -a | grep $active_device | awk '{printf "%-17s:  %s\n" ,$2, $1}'
