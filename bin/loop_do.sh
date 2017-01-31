#!/bin/sh

set -e

usage()
{
	prog=$(basename "$0")
	echo "Usage: $prog <loop image> <command line>"
}

if [ $# -lt 2 ]; then
	usage
	exit 1
fi

loop_img=$1
shift

sudo mount -o loop "$loop_img" /mnt
sudo "$@"
sync
sync
sync
sudo umount /mnt
