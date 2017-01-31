#!/bin/sh

is_mount_point()
{
	path="$1"
	cut -d ' ' -f 2 /proc/mounts | grep -q "^$path\$"
}

for mediam in /media/*; do
	if is_mount_point "$mediam" && [ -f "$mediam/.autorun" ]; then
		m=$(basename "$mediam")
		echo -n "Execute .autorun on $m [y/N]: "
		read -r is_run
		if echo "$is_run" | grep -q -e '[Y|y]' ; then
			bash "$mediam/.autorun"
		fi
	fi
done
