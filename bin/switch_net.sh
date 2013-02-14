#!/bin/bash

source caritas_functions.sh

INTERNAL_DOMAINS=

load_config

prog=$(basename $0)

usage()
{
	echo "Usage: $prog <home|work>"
}

if [ $# -ne 1 ]; then
	usage
	exit -1
fi

tnet=$1
if [ $tnet != "home" -a $tnet != "work" ]; then
	usage
	exit -1
fi

if [ "$tnet" == "work" ]; then
	sudo cp /etc/apt/apt.conf.avail/99proxy /etc/apt/apt.conf.d
	# gconftool-2 -s -t string /system/proxy/mode auto
	gsettings set org.gnome.system.proxy mode manual
	gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8', $INTERNAL_DOMAINS]"
else
	sudo rm -f /etc/apt/apt.conf.d/99proxy
	# gconftool-2 -s -t string /system/proxy/mode none
	gsettings set org.gnome.system.proxy mode none
	gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8']"
fi
