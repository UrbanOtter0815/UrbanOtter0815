#!/bin/sh

# Initialize variables
active_device=""
active_device_mac=""

# Loop through network devices
for device in $(networksetup -listallhardwareports | awk '/Device/{print $2}'); do
    ifout=$(ifconfig "$device" 2>/dev/null)
    if echo "$ifout" | grep -q 'status: active'; then
        active_device="$device"
        active_device_mac=$(echo "$ifout" | awk '/ether/{print $2}')
        break
    fi
done

# Check if an active device was found
if [ -z "$active_device" ]; then
    echo "No active network device found."
    exit 1
fi

# Print active device information
echo "\033[37mAvailable network devices on $active_device:\033[0m";
arp -a | grep $active_device | awk '{printf "%-17s:  %s\n" ,$2, $1}'