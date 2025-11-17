#!/bin/sh
###############################################################################
# File        : highlight-current-day-calendar.sh
# Description : Prints the calendar for the current year, with the current day
#               highlighted in red in the current month. The formatting aligns
#               all months in columns. The script is locale-independent and
#               works in standard shells supporting awk and cal.
# Usage       : ./highlight-current-day-calendar.sh
# Arguments   : None
# Author      : Stephan Stumpf
# Date        : 2025-11-17
# Version     : 1.0
# previous command: cal -y | awk -v month="`date +%m`" -v day="`date +%e` " '{m=int((NR-3)/8)*3+1; for (i=0;i<3;i++) {t[i]=substr($0,1+i*22,20) " "; if (m+i==month) sub(day,"\033[0;31m&\033[0m",t[i]);} print t[0],t[1],t[2];}'
###############################################################################

# Print the full year calendar.
# Pipe the output to awk for post-processing.
cal -y | \
awk \
  -v month="`date +%m`" \                # Set 'month' variable to current month as a number (01-12)
  -v day="`date +%e` " \                 # Set 'day' variable to current day followed by a space (handles single-digit days)

'
{
  m = int((NR-3)/8)*3+1;                 # Calculate month block index: 8 lines per row, 3 months per row
  for (i = 0; i < 3; i++) {
    t[i] = substr($0, 1 + i*22, 20) " "; # Extract columns for each of the 3 months, extend width for alignment
    if (m + i == month)
      sub(day, "\033[0;31m&\033[0m", t[i]); # If current block is the current month, highlight today in red
  }
  print t[0], t[1], t[2];                # Print the three processed month columns for this line
}
'

# End of script documentation
