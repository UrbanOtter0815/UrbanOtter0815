#!/bin/sh

# /usr/bin/curl --silent "http://www.accuweather.com/en/de/birkenau/69488/current-weather/168733" | /usr/bin/grep "\-xl" | /usr/bin/grep -o -e "http:\/\/.*\.png" | /usr/bin/xargs /usr/bin/curl --silent -o /Users/stebbele/GeekTool/weather1.png
# /usr/bin/curl --silent "http://www.accuweather.com/ja/jp/machida-shi/224375/current-weather/224375" | /usr/bin/grep "\-xl" | /usr/bin/grep -o -e "http:\/\/.*\.png" | /usr/bin/xargs /usr/bin/curl --silent -o /Users/stebbele/GeekTool/weather1.png
# weather(){ curl -s "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=${@:-<YOURZIPORLOCATION>}"|perl -ne '/<title>([^<]+)/&&printf "%s: ",$1;/<fcttext>([^<]+)/&&print $1,"\n"';}
# curl --silent "https://www.yahoo.com/news/weather/germany/birkenau/birkenau-12835620" | grep "current-weather" | sed "s/.*background\:url.'//g" | sed "s/'. no.*.//g" | xargs curl --silent -o /Users/stebbele/GeekTool/weather1.png
# write xml to variable
w_xml=$(curl --silent "http://weather.tuxnet24.de/?id=12835620&mode=xml");
w_img=$(xmllint --xpath "string(//current_image)" - <<<"$w_xml" | xargs);
curl --silent $w_img >> /Users/stebbele/GeekTool/weather.gif 
