#!/usr/bin/env bash

set -e

source caritas_functions.sh

USB_BDEV=

load_config

usage()
{
	prog=$(basename "$0")
	echo "Usage: $prog <command line>"
}

is_usb_bdev()
{
	local bdev="$1"
	readlink /sys/class/block/"$bdev" | grep -qe '/usb[0-9]/[0-9]-[0-9]/'
}

find_usb_bdev()
{
	for bdev in /sys/class/block/sd[b-z]; do
		bdev=$(basename "$bdev")
		if is_usb_bdev "$bdev"; then
			if [ -n "$USB_BDEV" ]; then
				die "Mutiple USB devices: $USB_BDEV and $bdev, you specify manually"
			else
				USB_BDEV=$bdev
			fi
		fi
	done
	if [ -n "$USB_BDEV" ]; then
		if [ -e "/sys/class/block/${USB_BDEV}1" ]; then
			USB_BDEV="${USB_BDEV}1"
		fi
	fi
}

wait_find_usb_bdev()
{
	while true; do
		find_usb_bdev
		if [ -n "$USB_BDEV" ]; then
			break
		fi
		echo "Waiting for usb disk ready ..."
		sleep 1
	done
}

if [ $# -lt 1 ]; then
	usage
	exit 1
fi

if [ -z "$USB_BDEV" ]; then
	wait_find_usb_bdev
	if ! is_usb_bdev "$USB_BDEV"; then
		echo "$USB_BDEV"
		exit 1
	fi
fi

sudo mount "/dev/$USB_BDEV" /mnt
sudo "$@"
sudo ls -lrt /mnt
sync
sync
sync
sudo umount /mnt
