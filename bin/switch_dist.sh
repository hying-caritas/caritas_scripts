#!/bin/sh

prog=$(basename $0)

usage()
{
	echo "Usage: $prog <testing|sid>"
}

current_dist()
{
	if grep sid /etc/apt/sources.list > /dev/null; then
		echo sid
	else
		echo testing
	fi
}

if [ $# -ne 1 ]; then
	usage
	exit 1
fi

tdist=$1
if [ $tdist != "sid" -a $tdist != "testing" ]; then
	usage
	exit 1
fi

cdist=$(current_dist)
if [ "$tdist" != "$cdist" ]; then
	sudo sed -i '1,$s/'$cdist/$tdist'/g' /etc/apt/sources.list
	sudo rm -rf /var/lib/apt/lists.$cdist
	sudo mv /var/lib/apt/lists /var/lib/apt/lists.$cdist
	if [ -d /var/lib/apt/lists.$tdist ]; then
		sudo mv /var/lib/apt/lists.$tdist /var/lib/apt/lists
	else
		sudo mkdir /var/lib/apt/lists
	fi
fi

sudo apt-get update
