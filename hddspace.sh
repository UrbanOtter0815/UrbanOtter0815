#!/bin/bash

###############################################################################
# Script Name:       volume_space_report.sh
# Description:       This script provides information about free disk space on 
#                    mounted volumes in macOS systems. It includes functions to:
#                    - Show a table with volumes and free space ("all_in_one")
#                    - List only the free space of all volumes ("size")
#                    - List all volume names ("volume_name")
#                    The output format adapts according to the macOS version.
#
# Usage:             ./volume_space_report.sh [one|size|volume]
#
# Author:            Stephan Stumpf
# Created:           2025-11-17
#
# Parameters:
#   one      - Shows volumes with their free space in a formatted table
#   size     - Lists only the free space of all volumes
#   volume   - Lists all mounted volume names
#
# Notes:
#   - Only one argument is allowed.
#   - The script adapts 'df' flags based on the operating system version
#
###############################################################################

# Detect macOS version and derive the major version number, then select the
# appropriate 'df' command flag for newer or older systems
osxversion=`/usr/bin/sw_vers|grep 'ProductVersion'|sed 's/[^0-9]*//g'`
osxversion=`echo ${osxversion:2:1}`

if [ $osxversion -ge 6 ]; then
   space="df -H"    # Use human-readable output, with powers of 1000, for macOS 10.6 or newer
else
   space="df -h"    # Use human-readable output, with powers of 1024, for older systems
fi

###############################################################################
# Function: all_in_one
# Description:
#   Prints a formatted table listing each volume and its free space.
# Usage:
#   all_in_one
###############################################################################
function all_in_one {
   proto_table=$(echo "|"Volume"|"Free"\n"
   ls /Volumes/ | while read FILE; do
      free=`$space /Volumes/"$FILE"`
      free=`echo $free | awk '{print $11}'` 
      echo "|""$FILE""|"$free"\n"
   done)
   # Formats the output as a table for readability
   echo -e $proto_table | sed 's/ |/|/g'| column -c 2 -s "|" -t
}

###############################################################################
# Function: size
# Description:
#   Lists only the free space for all volumes.
# Usage:
#   size
###############################################################################
function size {
   free=`$space /Volumes/*| grep -v used | awk '{ print $4 }' | sed 's/[^A-MG-Za-mg-z0-9]\.//g;s/i//g'`
   for (( i=2; i<=$(echo "$free"|wc -l); i++ ));do
      echo "$free"|sed -n $i"$n{p;}"
   done
}

###############################################################################
# Function: volume_name
# Description:
#   Lists the names of all mounted volumes.
# Usage:
#   volume_name
###############################################################################
function volume_name {
   ls /Volumes/ | while read FILE; do echo "$FILE"; done
}

###############################################################################
# Function: parameters
# Description:
#   Prints out valid command line parameters for script usage.
# Usage:
#   parameters
###############################################################################
function parameters {
   echo "Valid parameters are: \"one\", \"size\" and \"volume\""
}

# Parameter handling and control flow:
# - Only one parameter is allowed; prints a warning if more than one is given.
# - Executes the function corresponding to the given parameter.
if [ $# -gt 1 ]; then
   echo "Only one parameter is allowed."
   parameters
elif [ $# -eq 1 ]; then
   case "$1" in
      "one")
      all_in_one;
      ;;
      "size")
      size;
      ;;
      "volume")
      volume_name;
      ;;
      *)
      echo "The parameter" $1 "does not exist."
      parameters;
      ;;
   esac
else
   echo "Sorry, but you have to supply a parameter."
   parameters
fi
