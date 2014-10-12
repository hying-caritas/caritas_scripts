#!/bin/bash

while read line; do
	for ((i=0; i < 8; i++)); do
		echo -n "$i         "
	done
	echo
	for ((i=0; i < 8; i++)); do
		echo -n "1234567890"
	done
	echo
	echo "$line"
done
