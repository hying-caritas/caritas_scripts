#!/bin/bash
#TAGS: onkyo, mp3

set -e

flat_file_name()
{
	fn="$1"
	fn=${fn#./}
	nfn=$(echo "$fn" | tr / '#')
	mv "$fn" "$nfn"
}

flat_file_name "$@"
