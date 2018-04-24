#!/bin/sh

usage()
{
	echo "Usage: $(basename $0) <device name>"
	exit 1
}

name=$1
id=$(xinput --list --id-only "$name")

[ -n "$id" ] || usage

if xinput --list-props "$id" | grep -q "Device Enabled ([0-9]\+):\s*1"; then
	xinput --disable "$id"
else
	xinput --enable "$id"
fi
