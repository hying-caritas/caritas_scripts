#!/bin/bash

usage()
{
	echo "Usage: killqemu [-<signal>] <vm name>" 1>&2
	exit 1
}

[[ $# < 1 ]] && usage

name=$1
shift

pids=$(pgrep -f "qemu-system-.* -name $name")

if [[ $pids ]]; then
	kill "$@" $pids
else
	echo "No such VM!" 1>&2
	exit 2
fi
