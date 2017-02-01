#!/usr/bin/env bash

prog="${1:0:15}"
shift

pgrep -xu "$USER" "$prog" > /dev/null ||
	exec "$@"
