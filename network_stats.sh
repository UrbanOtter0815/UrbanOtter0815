#!/bin/sh

services=$(networksetup -listnetworkserviceorder | grep 'Hardware Port')
# export LC_ALL=en_US.UTF-8

while read line; do
    sname=$(echo $line | awk -F  "(, )|(: )|[)]" '{print $2}')
    sdev=$(echo $line | awk -F  "(, )|(: )|[)]" '{print $4}')
    #echo "Current service: $sname, $sdev, $currentservice"
    if [ -n "$sdev" ]; then
        ifout="$(ifconfig $sdev 2>/dev/null)"
        echo "$ifout" | grep 'status: active' > /dev/null 2>&1
        rc="$?"
        if [ "$rc" -eq 0 ]; then
            currentdevice="$sdev"
        fi
    fi
done <<< "$(echo "$services")"

# find out active utun device (active one is containing a netmask entry)
currentvpn=""
ifconfig utun0 | head -3 | grep netmask > /dev/null
if [[ $? -eq 0 ]] ;  then       currentvpn="utun0"; fi
ifconfig utun1 | head -3 | grep netmask > /dev/null
if [[ $? -eq 0 ]] ;  then       currentvpn="utun1"; fi
ifconfig utun2 | head -3 | grep netmask > /dev/null
if [[ $? -eq 0 ]] ;  then       currentvpn="utun2"; fi
ifconfig ppp0 | head -3 | grep netmask > /dev/null
if [[ $? -eq 0 ]] ;  then       currentvpn="ppp0"; fi
# ———8<———

# echo VPN-Device: $currentvpn
# echo Current Device: $currentdevice

# ifconfig $currentvpn > /dev/null
# if [[ $? -eq 0 ]] ; then
if [[ $currentvpn != "" ]] ; then

    echo "\033[37mNetwork stats on $currentdevice/$currentvpn: \033[40;37;7mVPN active!\033[0m"
    ifconfig  $currentdevice | grep "inet " | awk '{print $2}' | awk '{print "Internal IP: " $1}'
    ifconfig $currentvpn  | grep -m1 inet | awk '{print "External IP:",$4}'
#    netstat -ib -I $currentdevice | grep $currentdevice | awk '{print "in: "$7/1024 "KB, out: " $10/1024 "KB";exit}'
else
   echo "\033[37mNetwork stats on $currentdevice: \033[40;37;7mVPN not active!\033[0m"
   ifconfig  $currentdevice > /dev/null
   if [[ $? -eq 0 ]] ;
   then
     myvar1=`/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}'`  #  SSID
     myvar2=`ifconfig $currentdevice | grep "inet " | awk '{print $2}' | awk '{print "Internal IP: " $1}'`
     remoteip=$(dig +short myip.opendns.com @resolver1.opendns.com)
     if [[ $myvar1 != "" ]] ; then
       echo $myvar1 "(SSID" $myvar1")"
     fi
     if [[ $myvar2 != "" ]] ; then
       echo $myvar2
     fi
     if [[ $remoteip ]]; then
       echo "Remote IP:   $remoteip"
     else
       echo "Remote IP:   Unable To Determine"
     fi
#     netstat -ib -I $currentdevice | grep $currentdevice | awk '{print "in: "$7/1024 "KB, out: " $10/1024 "KB";exit}'
  fi
fi
