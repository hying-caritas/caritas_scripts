#!/bin/bash
#TAGS: kernel

source caritas_functions.sh

source_host=
target_host=
target_mac=

src_port=
tgt_port=
net_dev=

load_config

[ -z "$target_host -o -z "$target_mac" ] && die "Please configure target hostname/mac"

cfg source_host "$HOSTNAME"
cfg src_port 6665
cfg tgt_port 6666
cfg net_dev eth0

src_ip=$(lookup $source_host)
tgt_ip=$(lookup $target_host)

tgt_mac=$target_mac

sudo modprobe -r netconsole >& /dev/null
sudo modprobe netconsole netconsole="$src_port@$src_ip:/$net_dev,$tgt_port@$tgt_ip/$tgt_mac"
