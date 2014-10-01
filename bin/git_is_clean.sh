#!/bin/bash

status=$(git status --porcelain)

if [[ $1 == -q ]]; then
	if [[ $status ]]; then
		exit 1
	else
		exit 0
	fi
fi

if [[ $status ]]; then
	echo "$status"
else
	echo "git is clean!"
fi
