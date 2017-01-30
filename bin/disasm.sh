#!/bin/sh

usage()
{
	echo "Usage: $(basename $0) <obj file>"
	exit 1
}

[ $# -eq 1 ] || usage
obj="$1"
objdump -d "$obj" --no-show-raw-insn | cut -b 10-
