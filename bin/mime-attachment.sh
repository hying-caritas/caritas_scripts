#!/bin/bash

usage()
{
	prog=$(basename "$0")
	echo "$prog <file name>" 1>&2
	exit 1
}

[[ $# -ne 1 ]] && usage

path=$1
[[ -f "$path" ]] || {
	echo "Error: file $path does not exist!" 1>&2
	exit 2
}
file=$(basename "$path" | iconv -t UTF-8) || {
	echo "Error: Invalid character in file name: $file!" 1>&2
	exit 3
}

qfile="=?UTF-8?B?$(echo -n "$file" | base64)?="

mime_type=application/octet-stream
[[ "$file" =~ .*\.txt$ ]] && mime_type="text/plain; charset=utf-8"
[[ "$file" =~ .*\.mobi$ ]] && mime_type="application/x-mobipocket-ebook"

echo "Subject: $qfile
Content-Type: multipart/mixed;
 boundary=\"/-_=4987sdiuxmnkasj-frontier\"
MIME-Version: 1.0

--/-_=4987sdiuxmnkasj-frontier
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

--/-_=4987sdiuxmnkasj-frontier
Content-Type: $mime_type;
 name=\"$qfile\"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename=\"$qfile\"
"

base64 "$path"

echo "
--/-_=4987sdiuxmnkasj-frontier--"
