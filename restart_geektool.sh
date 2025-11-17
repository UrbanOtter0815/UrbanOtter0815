#!/bin/sh
#
#
ps aux | grep -ie "GeekTool.app"  | awk '{print $2}'  | xargs kill -9
sleep 2
#
/Applications/GeekTool.app/Contents/PlugIns/GeekTool.prefPane/Contents/Resources/GeekTool\ Helper.app/Contents/MacOS/GeekTool\ Helper &
