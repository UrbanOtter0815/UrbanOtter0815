#!/bin/sh

# Script Name: System Health Check
# Description: This script provides a summary of system health by reporting on RAM and CPU utilization,
#              Bluetooth and Wi-Fi status, Wake on LAN setting, system uptime, and the size of the Trash.
# Author: sstumpf
# Date: September 26, 2024

echo "\033[37mSystem health:\033[0m"

# Memory Usage
#-------------------------------------------
# Calculate total memory in MB
system_memory_total=$(sysctl hw.memsize | awk '{printf "%.0f", $2 / 1024 / 1024}')

# Extract memory information and calculate free and used memory in MB
vm_stat_output=$(vm_stat)
free_memory=$(echo "$vm_stat_output" | awk '/Pages free/ {free=$3} END {printf "%.0f", free * 4096 / 1024 / 1024}')
used_memory=$(echo "$system_memory_total - $free_memory" | bc)

echo "  RAM Utilization:  Total: ${system_memory_total}M, Used: ${used_memory}M, Free: ${free_memory}M"
#-------------------------------------------

# CPU Utilization
percentage=$(/usr/bin/top -l 2 | grep -E "^CPU" | tail -1 | awk '{ print $3 + $5"%" }')
int=${percentage%.*} # Convert percentage to integer

# Display CPU utilization with graphical bar representation
if   (( int >=  1 && int <= 12 )); then bar="\033[32m▂\033[0m";
elif (( int >= 13 && int <= 25 )); then bar="\033[32m▂▃\033[0m";
elif (( int >= 26 && int <= 50 )); then bar="\033[32m▂▃\033[33m▄\033[0m";
elif (( int >= 51 && int <= 72 )); then bar="\033[32m▂▃\033[33m▄▅\033[0m";
elif (( int >= 73 && int <= 90 )); then bar="\033[32m▂▃\033[33m▄▅\033[31m▆\033[0m";
else                                    bar="\033[32m▂▃\033[33m▄▅\033[31m▆▇\033[0m";
fi

echo "  CPU Utilization:  ${int}% $bar"

# Bluetooth Status
if [ $(/opt/homebrew/bin/blueutil | grep "Power:" | awk '{print $2}') -eq "1" ]; then
    echo "        Bluetooth:  On"
else
    echo "        Bluetooth:  Off"
fi

# Get the current audio volume
read volume muted <<< $(osascript -e "output volume of (get volume settings) & output muted of (get volume settings)" | tr ',' ' ')
if [ "$muted" = "true" ]; then
  echo "     Audio Volume:  0%"
else
  echo "     Audio Volume:  $volume%"
fi

# Wi-Fi Status Update (10-May-2024)
# wifi_info=$(sudo wdutil info)
#power_status=$(networksetup -getairportpower en0 | awk '{ if ($NF == "On" || $NF == "Off") { $NF=" " $NF } print }')
#echo "$power_status"

# Dynamically find the Wi-Fi interface name
wifi_device=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $2; exit}')

if [ -z "$wifi_device" ]; then
    power_status="Wi-Fi Power:    Off"
else
    power_status=$(networksetup -getairportpower "$wifi_device" | awk '{ if ($NF == "On" || $NF == "Off") { $NF=" " $NF } print }')
    echo "$power_status"
fi


# Wake on LAN Status
wake_on_lan=$(system_profiler SPPowerDataType | grep "Wake on LAN" | head -1 | awk '{print $4}')
echo "      Wake on LAN:  ${wake_on_lan}"

# Uptime Calculation
boot_time=$(sysctl -n kern.boottime | awk '{print $4}' | tr -d ',')
current_time=$(date +%s)
uptime_seconds=$((current_time - boot_time))

days=$((uptime_seconds / 86400))
hours=$(( (uptime_seconds % 86400) / 3600 ))
minutes=$(( (uptime_seconds % 3600) / 60 ))

format() 
{
  echo "$1 $2$( [ "$1" -eq 1 ] || echo "s" )"
}
echo "           Uptime:  $(format $days day) $(format $hours hour) $(format $minutes minute)"

# Size of Trashcan
trash_size=$(du -sh $HOME/.Trash/ | awk '{print $1}')
if [[ $trash_size != "0B" ]]; then
   printf "       Trash Size:  ${trash_size}\n"
fi