#!/bin/sh

set -e

program=$(basename "$0")
deb=$1
ndeb=$(echo "$deb" | sed '1,$s/\.deb$/_modified.deb/')
tmp=$(mktemp "$program")

trap 'rm -rf $tmp' EXIT

dpkg-deb -R "$deb" "$tmp"
vim "$tmp/DEBIAN/control"
dpkg-deb -b "$tmp" "$ndeb"
