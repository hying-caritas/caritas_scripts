#!/bin/bash

set -e

usage()
{
	echo "Usage: `basename $0` <loop image> <command line>"
}

if [ $# -lt 2 ]; then
	usage
	exit 1
fi

loop_img=$1
shift

sudo mount -o loop $loop_img /mnt
sudo "$@"
sync
sync
sync
sudo umount /mnt
