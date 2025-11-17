#!/bin/sh

###############################################################################
# Optimized Network Information Script for macOS
# 
# This script retrieves and displays detailed network information for all 
# network interfaces on a macOS system. It includes functionality to list 
# network ports, retrieve manufacturer information linked to MAC addresses, 
# convert subnet masks to CIDR notation, and check VPN status.
#
# Author: Stephan Stumpf
# Date: January 27, 2025
###############################################################################

# Define the directory for the OUI file (to retrieve MAC address manufacturers)
#ouidir="/var/lib/ieee-data"  # Ensure this directory exists and contains oui.txt
export LC_NUMERIC="en_US"

# Function: mask2cdr
# Converts an IP subnet mask to CIDR notation
mask2cdr () {
    local x=${1##*255.}
    set -- 0^^^128^192^224^240^248^252^254^ $(( (${#1} - ${#x})*2 )) ${x%%.*}
    x=${1%%$3*}
    echo $(( $2 + (${#x}/4) ))
}

# Function: statusvpn
# Check if VPN is active
function statusvpn () {
    # check_vpn:        Check if VPN is active
    # Example usage
    # check_vpn && exit 1

    vpn_interfaces=$(ifconfig -a | grep -E '^(utun|tun|ppp)')     # Check for active utun, tun, or ppp interfaces

    # Use scutil to verify network interface information
    scutil_output=$(scutil --nwi)

    # Check if any VPN-related interfaces are actually in use
    vpn_active=$(echo "$scutil_output" | grep -E 'utun|tun|ppp')

    if [[ -n "$vpn_interfaces" && -n "$vpn_active" ]]; then
        echo "Connected"
        return 0
    else
        echo "Disconnected"
        return 1
    fi
}


echo "\033[0m\033[37mNetwork info:\033[0m"

# Check VPN status
state=$(statusvpn)

# Get public IP
if [[ $state = "Connected" ]]; then
    vpn_status="VPN active!"
    remoteip="No remote IP available"
else
    vpn_status="VPN not active!"
    remoteip=$(dig +short +time=2 myip.opendns.com @resolver1.opendns.com | awk '{print $1}')
fi

echo "  VPN Status:   $vpn_status"
echo "  Remote IP:    $remoteip"
echo ""

# Retrieve all active network interfaces
NetworkPorts=$(ifconfig -uv | grep '^[a-z0-9]' | awk -F : '{print $1}')

# Process each network interface
for val in $NetworkPorts; do
    # Extract basic details using networksetup and ipconfig
    ifconfig_output=$(ifconfig -uv "$val")
    netstat_output=$(netstat -ib -I "$val")

    ipaddress=$(ipconfig getifaddr "$val")
    macaddress=$(echo "$ifconfig_output" | grep 'ether ' | awk '{print $2}')
    netmask=$(ipconfig getoption "$val" subnet_mask)
    router=$(ipconfig getpacket "$val" | grep 'router (ip_mult):' | sed 's/.*router (ip_mult): {\([^}]*\)}.*/\1/')
    
    # Retrieve additional details
    if [[ $state = "Connected" ]]; then
        dnsserver="8.8.8.8"
    else
        dnsserver=$(ipconfig getoption "$val" domain_name_server)
    fi
    
    # Calculate traffic statistics in MB
    myvar1=$(echo "$netstat_output" | grep -e "$val" -m 1 | awk '{print $7}')
    myvar2=$(echo "$netstat_output" | grep -e "$val" -m 1 | awk '{print $10}')
    myvar1=${myvar1:-0}
    myvar2=${myvar2:-0}

    kbin_measure=$(bc <<< "scale=2; $myvar1/1024/1024")
    kbout_measure=$(bc <<< "scale=2; $myvar2/1024/1024")

    # Either return the IN in GB or MB
    if (( $(echo "$kbin_measure < 1024" | bc -l) )); then
        kbin=$(printf "%'.2f" "$(bc <<< "scale=2; $myvar1/1024")") # formatted with decimal 1000
        unit_in="MB"
    else
        kbin=$(printf "%'.2f" "$(bc <<< "scale=2; $myvar1/1024/1024/1024")") # formatted with decimal 1000
        unit_in="GB"
    fi

    # Either return the OUT in GB or MB
    if (( $(echo "$kbout_measure < 1024" | bc -l) )); then
        kbout=$(printf "%'.2f" "$(bc <<< "scale=2; $myvar2/1024")") # formatted with decimal 1000
        unit_out="MB"
    else
        #kbout=$(bc <<< "scale=2; $myvar2/1024/1024")
        kbout=$(printf "%'.2f" "$(bc <<< "scale=2; $myvar2/1024/1024/1024")") # formatted with decimal 1000
        unit_out="GB"
    fi

    #kbout=$(printf "%'.2f" "$(bc <<< "scale=2; $myvar2/1024/1024")") # formatted with decimal 1000
    #kbout=$(bc <<< "scale=2; $myvar2/1024/1024") # unformatted
    
    # Output details for active interfaces only
    activated=$(echo "$ifconfig_output" | grep 'status: ' | awk '{print $2}')
    quality=$(echo "$ifconfig_output" | grep 'link quality:' | awk '{print $3, $4}')
    networkspeed=$(echo "$ifconfig_output" | grep 'link rate:' | awk '{print $3, $4}' | head -1)

    if [ "$activated" = "active" ] && [[ -n "$ipaddress" ]]; then
        echo "\033[0m\033[37mInterface: $val\033[0m"
        echo "  IP Address:   $ipaddress"
 #       echo "  Subnet Mask:  ${netmask:-Unknown}"
        echo "  Router:       ${router:-Unknown}"
#        echo "  IP CIDR:      ${ipaddress}/$(mask2cdr ${netmask:-255.255.255.0})"
        echo "  DNS Server:   ${dnsserver:-Unknown}"
        echo "  MAC Address:  $macaddress"
        echo "  Link Quality: ${quality:-Unknown}"
        echo "  Speed:        ${networkspeed:-Unknown}"
        echo "  Traffic:      In: ${kbin} ${unit_in}, Out: ${kbout} ${unit_out}"
        
        echo ""
    fi
done

exit 0
