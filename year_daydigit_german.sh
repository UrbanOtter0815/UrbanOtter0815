#!/bin/sh

date "+%A" | sed -e 's/Monday/Montag/g' -e 's/Tuesday/Dienstag/g' -e 's/Wednesday/Mittwoch/g' -e 's/Thursday/Donnerstag/g' -e 's/Friday/Freitag/g' -e 's/Saturday/Samstag/g' -e 's/Sunday/Sonntag/g'