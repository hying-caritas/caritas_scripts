#!/bin/sh
#TAGS: onkyo, mp3

from="$1"
dfrom=$(dirname "$from")
ffrom=$(basename "$from")
fto=$(hanzi2pinyin.py "$ffrom")
to="$dfrom/$fto"
if [ "$from" != "$to" ]; then
	echo "$to"
	mv "$from" "$to"
fi
