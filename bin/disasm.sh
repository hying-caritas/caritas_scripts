#!/bin/sh

usage()
{
	prog=$(basename "$0")
	echo "Usage: $prog <obj file>"
	exit 1
}

[ $# -eq 1 ] || usage
obj="$1"
objdump -d "$obj" --no-show-raw-insn | cut -b 10-
