#!/bin/sh
#
# Last Update: 22-Apr-2021
#
# This script can be used to check up- and downloadspeed provided by the Ookla tool Speedtest
# Speedtest for CLI can be downloaded here: https://www.speedtest.net/apps/cli
# Alternatively by    /usr/local/bin/brew tap teamookla/speedtest
#                     /usr/local/bin/brew install speedtest --force
# Usage:              /usr/local/bin/speedtest --help
#
echo "\033[0m\033[37mSpeedtest.net\033[0m"

# Files & locations
FILE=~/Library/Logs/speedtest.out
FILE_HIST=~/Library/Logs/speedhist.out

if [ ! -f "$FILE" ]; then
  ex -sc '1i|# -----------------' -cx $FILE_HIST
  ex -sc '1i|# Speed history' -cx $FILE_HIST
  ex -sc '1i|# -----------------' -cx $FILE_HIST
fi

if [ -f "$FILE" ]; then
   create_date_prev=$(ls -latr $FILE | awk '{print $6" "$7" "$8}')
   down_previous=$(more $FILE | awk "/Download:/"'{print $3" "$4; exit}')
   up_previous=$(more $FILE | awk "/Upload:/"'{print $3" "$4; exit}')
   rm "$FILE"
else
   create_date_prev="none"
   down_previous="none ↓"
   up_previous="none ↑"
fi
/usr/local/bin/speedtest >> $FILE

# append the measures to speedhist.out
echo "------——— ✂ ———------" >> $FILE_HIST
echo $create_date_prev >> $FILE_HIST
echo $down_previous >> $FILE_HIST
echo $up_previous >> $FILE_HIST
#cat $FILE >> $FILE_HIST

#
create_date=$(ls -latr $FILE | awk '{print $6" "$7" "$8}')
echo "Last updated: $create_date (prev. $create_date_prev)"
echo
more $FILE | awk "/Server:/"'{print $1"       "$2" "$3" "$4; exit}'
more $FILE | awk "/ISP:/"'{print $1"          "$2" "$3" "$4; exit}'
down_now=$(more $FILE | awk "/Download:/"'{print $2"     "$3" "$4; exit}')
echo "↓ $down_now (prev. $down_previous)"
up_now=$(more $FILE | awk "/Upload:/"'{print $2"       "$3" "$4; exit}')
echo "↑ $up_now (prev. $up_previous)"
