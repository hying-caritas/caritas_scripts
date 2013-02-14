#!/bin/bash

source caritas_functions.sh

usage()
{
    echo "$(basename $0) <hosts_addon>"
    exit 1
}

[ $# -eq 1 ] || usage

addon="$1"
tmp=$(temp_file)

trap "rm -rf $tmp" EXIT

merge_magic="# ====== added by merge hosts ======"

sed '/^'"$merge_magic"'/,$d' < /etc/hosts > $tmp
echo "$merge_magic" >> $tmp
cat "$addon" >> $tmp

chmod 0644 $tmp
sudo mv $tmp /etc/hosts
