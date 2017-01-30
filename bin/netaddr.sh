#!/bin/sh

net_dev=$1

export PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin

ifconfig $net_dev | grep 'inet addr' | cut -d ':' -f 2 | cut -d ' ' -f 1
