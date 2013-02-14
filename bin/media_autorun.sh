#!/bin/bash

is_mount_point()
{
	local path="$1"
	cut -d ' ' -f 2 /proc/mounts | grep -q "^$path\$"
}

for mediam in /media/*; do
	if is_mount_point $mediam && [ -f $mediam/.autorun ]; then
		m=$(basename $mediam)
		echo -n "Execute .autorun on $m [y/N]: "
		read is_run
		if [[ "$is_run" =~ [Y|y] ]]; then
			bash "$mediam/.autorun"
		fi
	fi
done
