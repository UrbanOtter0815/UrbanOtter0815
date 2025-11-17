#!/bin/bash
# Script to monitor network bandwidth usage for a specified network interface.
# Default interface is 'en0' if no parameter is provided.
# Bandwidth is displayed in megabits per second (mb/s).
# Usage: ./bandwith_monitor.sh en10
#        ./bandwith_monitor.sh analyze - analyzes the content of bandwidth_output.txt
#


if [ "$1" = "analyze" ]; then
    awk '
    {
        total_entries++
        if ($8 == "DOWN:" && $12 == "UP:" && $9 ~ /^[0-9.]+$/ && $13 ~ /^[0-9.]+$/) {
            down_sum += $9
            up_sum += $13
            valid_entries++
        } 
        else {
            failed++
        }
    }
    END {
        printf "\033[40;37;7mAnalysis Report\033[0m\n"
        printf "Total entries: %d\n", total_entries
        printf "Valid measurements: %d\n", valid_entries
        printf "Average DOWN: %.2f Mbit/s\n", (valid_entries ? down_sum / valid_entries : 0)
        printf "Average UP: %.2f Mbit/s\n", (valid_entries ? up_sum / valid_entries : 0)
        printf "Failed measurements: %d\n", failed
    }' ~/Scripts/Geektool/bandwidth_out.txt
    exit 0
fi

# Check if speedtest-cli is installed: /opt/homebrew/bin/speedtest-cli
if ! command -v /opt/homebrew/bin/speedtest-cli &> /dev/null; then
    echo "speedtest-cli is not installed. Please install it using Homebrew."
    exit 1
fi

# Check if network interface is provided
if [ -z "$1" ]; then
    echo "Please provide a network interface (e.g., en0, en1) or 'analyze'"
    exit 1
fi

# Check interface existence
if ! networksetup -listallhardwareports | grep -q "Device: $1$"; then
    echo "Error: Interface $1 does not exist on this system"
    echo "Available interfaces:"
    networksetup -listallhardwareports | awk -F': ' '/Device/ {print $2}'
    exit 1
fi

# Check interface activity
if [ -z "$(ipconfig getifaddr "$1")" ]; then
    echo "Error: Interface $1 exists but is not active"
    echo "Current active interfaces:"
    scutil --nwi | awk '/^Network interfaces/ {active=1} active && /address/ {print $1}'
    exit 1
fi

# Run speedtest-cli and capture output
OUTPUT=$(/opt/homebrew/bin/speedtest-cli --simple)

# Extract download and upload speeds
DOWNLOAD_SPEED=$(echo "$OUTPUT" | grep "Download:" | cut -d ':' -f2- | xargs)
UPLOAD_SPEED=$(echo "$OUTPUT" | grep "Upload:" | cut -d ':' -f2- | xargs)

# Format and print the output
#echo "LAN speed on $1 is DOWN: $DOWNLOAD_SPEED / UP: $UPLOAD_SPEED"
#printf "\033[40;37;7mLAN speed on $1 is DOWN: $DOWNLOAD_SPEED / UP: $UPLOAD_SPEED\033[0m\n"
if [[ -n "$DOWNLOAD_SPEED" && -n "$UPLOAD_SPEED" && \
      "$DOWNLOAD_SPEED" =~ ^[0-9.]+ && "$UPLOAD_SPEED" =~ ^[0-9.]+ ]]; then
    printf "\033[40;37;7mLAN speed on $1 is DOWN: $DOWNLOAD_SPEED / UP: $UPLOAD_SPEED\033[0m\n"
    echo "$(date '+%Y-%m-%d %H:%M:%S'): LAN speed on $1 is DOWN: $DOWNLOAD_SPEED / UP: $UPLOAD_SPEED" >> ~/Scripts/Geektool/bandwidth_out.txt
else
    echo "Error: Invalid speed measurements - DOWN: ${DOWNLOAD_SPEED:-null} / UP: ${UPLOAD_SPEED:-null}"
    exit 1
fi
