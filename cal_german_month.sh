#!/bin/sh
export LC_TIME=de_DE
# cal | awk '{ print " "$0; getline; print " Mo Di Mi Do Fr Sa So"; getline; if (substr($0,1,2) == " 1") print "                    1 "; do { prevline=$0; if (getline == 0) exit; print " " substr(prevline,4,17) " " substr($0,1,2) " "; } while (1) }'
# /usr/local/bin/gcal --starting-day=1
/opt/homebrew/bin/gcal --starting-day=1 --with-week-number
# cal | grep -C6 --color "\b$(date +%e)\b"
# /usr/bin/cal -3
