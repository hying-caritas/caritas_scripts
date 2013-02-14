#!/bin/bash

prog=$(basename $0)
usage()
{
	echo "$prog <time_spec>"
	exit 1
}

if [ $# != 1 ]; then
	usage
fi
time_spec=$1

DATE=$(date --rfc-3339=seconds -d "$time_spec" | cut -d '+' -f 1)
DATE_U=$(date -u -d "$DATE" +%s)
echo 0 | sudo_outf /sys/class/rtc/rtc0/wakealarm
echo $DATE_U | sudo_outf /sys/class/rtc/rtc0/wakealarm
