#!/bin/sh

###############################################################################
# Network Traffic Monitoring Script for macOS
# 
# This script identifies the currently active network service and device,
# retrieves the MAC address, and collects traffic statistics (bytes in/out) 
# for the active interface. It avoids multiple calls to ifconfig by storing 
# the output of ifconfig for each interface.
#
# Author: sstumpf
# Date: September 27, 2024
###############################################################################

# -----------------------------------------------------------------------------
# Retrieve a list of all network services and their associated hardware ports
# using networksetup. Extract both service name (e.g., "Wi-Fi") and device 
# name (e.g., "en0").
# -----------------------------------------------------------------------------
services=$(networksetup -listnetworkserviceorder | grep 'Hardware Port')

# Initialize variables to store the active service, device, and MAC address
currentservice=""
currentdevice=""
currentmac=""

# -----------------------------------------------------------------------------
# Loop through each line of network services. Extract the service name and 
# device name using awk. For each device, check if it is active using ifconfig. 
# If the device is active, store the service name, device name, and MAC address.
# -----------------------------------------------------------------------------
while read line; do
    # Extract the network service name and device (e.g., "Wi-Fi", "en0")
    sname=$(echo "$line" | awk -F  "(, )|(: )|[)]" '{print $2}')
    sdev=$(echo "$line" | awk -F  "(, )|(: )|[)]" '{print $4}')
    
    # Check if a valid device name exists
    if [ -n "$sdev" ]; then
        # Call ifconfig once and store its output for the current device
        ifout=$(ifconfig "$sdev" 2>/dev/null)
        
        # Check if the interface is active by looking for "status: active"
        echo "$ifout" | grep 'status: active' > /dev/null 2>&1
        rc="$?"
        
        # If the interface is active, save the current service, device, and MAC address
        if [ "$rc" -eq 0 ]; then
            currentservice="$sname"
            currentdevice="$sdev"
            currentmac=$(echo "$ifout" | awk '/ether/{print $2}')
        fi
    fi
done <<< "$(echo "$services")"

# -----------------------------------------------------------------------------
# Once the active device is identified, retrieve network traffic statistics 
# for the active interface using netstat.
# -----------------------------------------------------------------------------
if [ -n "$currentdevice" ]; then
    # Get bytes in (received) and bytes out (sent) for the current device
    myvar1=$(netstat -ib -I "$currentdevice" | grep -e "$currentdevice" -m 1 | awk '{print $7}')  # bytes in
    myvar2=$(netstat -ib -I "$currentdevice" | grep -e "$currentdevice" -m 1 | awk '{print $10}') # bytes out

    # -----------------------------------------------------------------------------
    # Convert the bytes received and sent into megabytes (MB) for better readability
    # -----------------------------------------------------------------------------
    kbin=$(echo "scale=2; $myvar1/1024/1024;" | bc)  # convert bytes to MB
    kbout=$(echo "scale=2; $myvar2/1024/1024;" | bc) # convert bytes to MB

    # -----------------------------------------------------------------------------
    # Print the current network traffic statistics for the active interface
    # -----------------------------------------------------------------------------
    echo "\033[37mNetwork performance:\033[0m"
    echo "      Active Network Service: $currentservice ($currentdevice)"
    echo "      MAC Address: $currentmac"
    echo "      Traffic $currentdevice: In: $kbin MB, Out: $kbout MB"
else
    # If no active device was found, print a message indicating no active service
    echo "No active network interface found."
fi


