#!/bin/sh
cal -y | awk -v month="`date +%m`" -v day="`date +%e` " '{m=int((NR-3)/8)*3+1; for (i=0;i<3;i++) {t[i]=substr($0,1+i*22,20) " "; if (m+i==month) sub(day,"\033[0;31m&\033[0m",t[i]);} print t[0],t[1],t[2];}'
