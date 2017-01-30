#!/bin/sh
#TAGS: onkyo, mp3

set -e

flat_rm_dir()
{
	dn="$1"
	if [ "$dn" == "." ]; then
		return
	fi
	rmdir "$dn"
}

flat_rm_dir "$@"
