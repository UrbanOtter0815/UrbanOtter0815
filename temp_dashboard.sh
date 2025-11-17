#!/bin/sh

#thedatefull=`date +%Y%m%d_%H:%M`
batt_temp=`/usr/local/bin/istats | grep "Battery temp:" | awk '{print $3}'`
cpu_temp=`/usr/local/bin/istats | grep "CPU temp:" | awk '{print $3 " " $4}'`
fan_speed=`/usr/local/bin/istats | grep "speed:" | awk '{print $4}'`
cpu_usage=`ps -A -o %cpu | awk '{s+=$1} END {print s}'`

#echo "---------------" $thedatefull" --------------"
#echo "CPU Usage      :" $cpu_usage "%"
echo "CPU Temperature: "$cpu_temp
echo "Fan Speed      :" $fan_speed "U/min"

# echo "  CPU Temperature: " $(/usr/local/bin/istats | grep "CPU temp:" | awk '{print $3 " " $4}')
