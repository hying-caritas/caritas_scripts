#!/bin/bash

usage()
{
	echo "$(basename $0) <file name>"
	exit 1
}

[[ $# -ne 1 ]] && usage

path=$1
file=$(basename "$path")
[[ -f "$path" ]] || {
	echo "Error: file: $path does not exist!"
	exit 2
}

echo "Subject: $file
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=/-_=4987sdiuxmnkasj-frontier

This is a message with multiple parts in MIME format.

--/-_=4987sdiuxmnkasj-frontier
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Disposition: inline

file: $file

--/-_=4987sdiuxmnkasj-frontier
Content-Type: application/octet-stream
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=\"$file\"

"

base64 "$path"

echo "
--/-_=4987sdiuxmnkasj-frontier--"
