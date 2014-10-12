#!/bin/bash

priorities_avail="required important standard optional extra"

usage()
{
	echo "Usage: $(basename $0) <priority>
  Available priorities are: $priorities_avail"
	exit 1
}

priority=${1:-required}
echo $priorities_avail | grep -qw $priority || usage

aptitude search "?priority($priority)" | cut -c 5- | cut -d ' ' -f 1 |
while read package; do
	if ! dpkg-query -W -f '${Status}' $package 2>/dev/null |
	     grep -q ' installed$'; then
		echo =========================================================================
		echo $package : "not installed"
		continue
	fi
	bins=$(dpkg-query -L $package | grep -e '/s\?bin/.\+')
	[[ $bins ]] || continue
	echo =========================================================================
	echo -n $package
	dpkg-query -W -f ': ${Binary:summary}\nHomepage: ${Homepage}\n' $package
	echo "$bins" |
	while read lcmd; do
		cmd=$(basename $lcmd)
		echo -n "  "
		whatis -l -s 1,8 $cmd 2> /dev/null || echo $cmd
	done
done
