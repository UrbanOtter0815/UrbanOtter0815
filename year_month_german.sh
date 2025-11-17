#!/bin/sh

date "+%B %Y" | sed -e 's/January/Januar/g' -e 's/February/Februar/g' \
                    -e 's/March/März/g' -e 's/May/Mai/g' -e 's/June/Juni/g' \
                    -e 's/July/Juli/g' -e 's/October/Oktober/g' \
                    -e 's/December/Dezember/g'
