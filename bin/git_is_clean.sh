#!/bin/sh

status=$(git status --porcelain)

if [ "x$1" = x-q ]; then
	if [ -n "$status" ]; then
		exit 1
	else
		exit 0
	fi
fi

if [ -n "$status" ]; then
	echo "$status"
else
	echo "git is clean!"
fi
