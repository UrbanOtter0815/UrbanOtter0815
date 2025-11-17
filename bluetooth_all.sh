#!/bin/bash

##########################################################
# Script Description:
# This script retrieves the Bluetooth device information 
# including Address, Vendor ID, Product ID, Battery Level,
# Firmware Version, Minor Type, and Services of connected 
# Bluetooth devices using the 'blueutil' and 'ioreg' 
# commands on macOS.
##########################################################

# Run blueutil command to list connected Bluetooth devices and extract their addresses
#connected_addresses=$(blueutil --connected | awk -F ', ' '/address:/ {print $2}')
#connected_addresses=$(blueutil --connected | awk -F ', ' '/address:/ {sub(/,$/, "", $2); print $2}')
#connected_addresses=$(blueutil --connected | awk -F 'address: ' '{print $2}' | cut -d ',' -f1)
connected_addresses=$(blueutil --connected | awk -F 'address: ' '{print $2}' | cut -d ',' -f1 | tr ':' '-')
#echo $connected_addresses


# Check if there are no connected devices
if [ -z "$connected_addresses" ]; then
    echo "No connected Bluetooth devices found."
    exit 1
fi

# Extract and print the Bluetooth device information of connected devices
echo "Connected Bluetooth Devices Information:"
echo "----------------------------------------"

# Initialize arrays to store device information
device_info=()

# Extract connected device information from ioreg for each address
for address in $connected_addresses; do
    # Run ioreg command to query device information for the current address
    current_device_info=$(ioreg -r -l -n AppleHSBluetoothDevice | grep -A 10 "\"Address\" = \"$address\"")

    # Check if device information is empty
    if [ -z "$current_device_info" ]; then
        echo "Error: Device information not found for address $address"
        continue
    fi

    # Add device information to the array
    device_info+=("$current_device_info")
done

# Check if any device information was found
if [ ${#device_info[@]} -eq 0 ]; then
    echo "No device information found for connected Bluetooth devices."
    exit 1
fi

# Print the extracted information
for info in "${device_info[@]}"; do
    echo "$info"
    echo "----------------------------------------"
done

exit 0