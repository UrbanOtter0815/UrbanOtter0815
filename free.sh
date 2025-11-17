#!/bin/bash
#
# Utility to display memory usage
#
# Author: sstumpf
# Last modify: 20-Apr-2024
#
#

# Get total memory using sysctl
total_bytes=$(sysctl -n hw.memsize)

# Get memory usage statistics from vm_stat
vm_stat_output=$(vm_stat)

# Parse vm_stat output for page size and memory page counts
page_size=$(echo "$vm_stat_output" | awk '/page size of/ {print $8}' | tr -d '.')
pages_free=$(echo "$vm_stat_output" | awk '/Pages free/ {print $3}' | tr -d '.')
pages_active=$(echo "$vm_stat_output" | awk '/Pages active/ {print $3}' | tr -d '.')
pages_inactive=$(echo "$vm_stat_output" | awk '/Pages inactive/ {print $3}' | tr -d '.')
pages_wired=$(echo "$vm_stat_output" | awk '/Pages wired down/ {print $4}' | tr -d '.')

# Convert page counts to bytes
free_bytes=$(echo "$pages_free * $page_size" | bc)
active_bytes=$(echo "$pages_active * $page_size" | bc)
inactive_bytes=$(echo "$pages_inactive * $page_size" | bc)
wired_bytes=$(echo "$pages_wired * $page_size" | bc)

# Calculate total used memory (active + inactive + wired)
used_bytes=$(echo "$active_bytes + $inactive_bytes + $wired_bytes" | bc)

# Format output based on size
format_output() {
  local bytes=$1
  local unit=""

  if [ "$bytes" -lt 1048576 ]; then
    # Less than 1 MB, display in KB
    bytes=$(echo "scale=2; $bytes / 1024" | bc)
    unit="KB"
  elif [ "$bytes" -lt 1073741824 ]; then
    # Less than 1 GB, display in MB
    bytes=$(echo "scale=2; $bytes / 1048576" | bc)
    unit="MB"
  else
    # Display in GB
    bytes=$(echo "scale=2; $bytes / 1073741824" | bc)
    unit="GB"
  fi

  echo "${bytes}${unit}"
}

# Display RAM utilization
total_formatted=$(format_output $total_bytes)
used_formatted=$(format_output $used_bytes)
free_formatted=$(format_output $free_bytes)

echo "  RAM Utilization: Total $total_formatted, Used $used_formatted, Free $free_formatted"