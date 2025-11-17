#!/bin/sh

###############################################################################
# Collected hardware specific information of the mac and attached devices
# 
# This script retrieves and displays detailed hardware information
#
# Author: Stephan Stumpf
# Date:   27-Jan-2025
# Update: 17-Apr-2025
###############################################################################

echo "\033[37mSystem info:\033[0m"
sExternalMACALService="http://dns.kittell.net/macaltext.php?address="

# Get computer name
computername=$(scutil --get ComputerName)

# Get serial number
#sSerialNumber=$(system_profiler SPHardwareDataType |grep "Serial Number (system)" | awk '{print $4}'  | cut -d/ -f1)
#echo $sSerialNumber

# Get operating system name and version - Start
OSVers=$( awk '/SOFTWARE LICENSE AGREEMENT FOR macOS/' '/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf' | awk -F 'macOS ' '{print $NF}' | awk '{print substr($0, 0, length($0)-1)}')

# Get operating system name and version
OSName=$( sw_vers -productVersion )
model=$(system_profiler SPHardwareDataType | grep "Model Identifier" | awk '{print $3}')
cores=$(system_profiler SPHardwareDataType | grep "Cores:" | awk '{print $5}')
start_disk=$(diskutil info / | grep 'Volume Name' | cut -c 31-)
#arch=$(/usr/bin/arch)
arch=$(/usr/bin/uname -m)
# arch="arm64"

# Get Screen resolution
# new 17.04.2025:

# Check for Retina display
if system_profiler SPDisplaysDataType | grep -qi "Retina"; then
  # Computer #1: Get effective (scaled) resolution for Retina
  # RETINA_RES=$(osascript -e 'tell application "Finder" to get bounds of window of desktop' | tr -d ',' | awk '{print $3 " x " $4}')
  #RETINA_RES=$(system_profiler SPDisplaysDataType | grep "Resolution: " | tr -d '()' | awk '{print $2 " x " $4}')
  RETINA_RES=$(system_profiler SPDisplaysDataType | grep "Resolution: " | awk '{sub(/.*Resolution: /,""); print}')
  resolution="$RETINA_RES"
  # echo "Retina Display Effective Resolution: $RETINA_RES"
else
  # Computer #2: Get physical resolution for external monitor
  EXTERNAL_RES=$(system_profiler SPDisplaysDataType | grep "Resolution:" | grep -v "Retina" | head -n1 | awk '{print $2 " x " $4}')
  if [ -n "$EXTERNAL_RES" ]; then
    resolution="$EXTERNAL_RES (ext. Monitor)"
    #echo "External Monitor Resolution: $EXTERNAL_RES"
  else
    # Fallback to primary display if no external monitor found
    PRIMARY_RES=$(system_profiler SPDisplaysDataType | grep "Resolution:" | head -n1 | awk '{print $2 " x " $4}')
    resolution="$PRIMARY_RES (primary Display)"
    #echo "Primary Display Resolution: $PRIMARY_RES"
  fi
fi

# Check if File Vault is activated
vault=$(fdesetup status | tr -d '.' | head -n 1)

# Output all collected information
echo "      Computer OS:  Mac OS X - $OSName $OSVers"
echo "Current User Name:  $(whoami) ($HOME)"
echo "    Computer Name:  $computername"
echo "            Model: " $model $(sysctl -n machdep.cpu.brand_string;) " / "$arch "/ "$cores "cores"
#echo "    Serial Number:  $sSerialNumber"
echo "     Startup Disk:  $start_disk"
echo "  Disk Encryption:  $vault"
echo "Screen Resolution:  $resolution"

exit 0
