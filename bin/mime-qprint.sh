#!/usr/bin/env bash

target_encoding=UTF-8

quote()
{
	xs=$(echo -n "$1" | od -A n -t x1)
	for x in $xs; do
		echo -n "=$x"
	done
}

string="$(cat)"

echo -n =?$target_encoding?Q?
for ((i=0; i<${#string}; i++)); do
	c=${string:$i:1}
	case "$c" in
		[[:space:]] | = | \?)
			quote "$c"
			;;
		[[:print:]])
			if [[ $c =~ [:ascii:] ]]; then
				echo -n "$c"
			else
				tc="$(echo "$c" | iconv -t "$target_encoding")" || {
					echo "Invalid input string!" 1>&2
					exit 1
				}
				quote "$tc"
			fi
			;;
		*)
			quote "$c"
			;;
	esac
done
echo -n "?="
