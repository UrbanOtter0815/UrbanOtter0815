#!/bin/sh
###############################################################################
# Script Name : calendar_output.sh
# Description : Outputs calendar information in German locale using system cal
#               and gcal utilities, with highlights and week numbers.
# Usage       : ./calendar_output.sh
# Dependencies: gcal (from Homebrew), locale de_DE, standard /bin/sh, awk, cal
# Author      : Stephan Stumpf
# Date        : 2025-11-17
###############################################################################

export LC_TIME=de_DE      # Set locale for time output to German

# cal | awk '{ print " "$0; getline; print " Mo Di Mi Do Fr Sa So"; getline; if (substr($0,1,2) == " 1") print "                    1 "; do { prevline=$0; if (getline == 0) exit; print " " substr(prevline,4,17) " " substr($0,1,2) " "; } while (1) }'
# Outputs calendar with days in German, formats lines using awk for German weekday labels and highlights the first day if present.

# /usr/local/bin/gcal --starting-day=1
# Generates a calendar using gcal, starting with Monday as the first weekday (default for German calendars).

/opt/homebrew/bin/gcal --starting-day=1 --with-week-number
# Uses Homebrew's gcal to display the calendar, starting week on Monday, and including week numbers for additional context.

# cal | grep -C6 --color "\b$(date +%e)\b"
# Highlights the current day in the calendar output and displays context rows for better visibility.

# /usr/bin/cal -3
# Outputs the previous, current, and next month calendar side by side for broader context.
