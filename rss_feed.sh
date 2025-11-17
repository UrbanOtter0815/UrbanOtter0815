#!/bin/sh

echo "\033[37mRSS Feed Heise-Ticker:\033[0m"
# LANG=de_DE.UTF-16
URL="http://heise.de.feedsportal.com/c/35207/f/653902/index.rss"
maxLength="500"
start="4"
end="10"

curl --silent "$URL" |
sed -e :a -e '$!N;s/\n//;ta' |
sed -e 's/<title>/\
<title>/g' |
sed -e 's/<\/title>/<\/title>\
/g' |
sed -e 's/<description>/\
<description>/g' |
sed -e 's/<\/description>/<\/description>\
/g' |
grep -E '(title>|description>)' |
sed -n "$start,$"'p' |
sed -e 's/<title>//' |
sed -e 's/<\/title>//' |
sed -e 's/<description>/   /' |
sed -e 's/<\/description>//' |
sed -e 's/<!\[CDATA\[//g' |
sed -e 's/\]\]>//g' |
sed -e 's/&lt;/</g' |
sed -e 's/&gt;/>/g' |
sed -e 's/<[^>]*>//g' |
cut -c 1-$maxLength |
head -$end |
sed G |
fmt 
