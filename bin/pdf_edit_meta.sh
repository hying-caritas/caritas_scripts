#!/bin/bash
#TAGS: ebook

set -e

source caritas_functions.sh

usage()
{
	prog=$(basename "$0")
	echo "$prog <pdf>"
	exit 1
}

clean()
{
	rm -rf "$tmp_meta" "$tmp_meta2" "$tmp_out"
}

[ $# -eq 1 ] || usage

pdf_in="$1"

trap clean EXIT

tmp_meta="$(temp_file pdftk_meta_)"
tmp_meta2="$(temp_file pdftk_meta_)"
tmp_out="$(temp_file pdftk_).pdf"

info_key="InfoKey: "
info_val="InfoValue: "

pdftk "$pdf_in" dump_data | \
	sed -n -e "/${info_key}Title/,+1p" -e "/${info_key}Author/,+1p" \
	    -e "/${info_key}Subject/,+1p" -e "/${info_key}Keywords/,+1p" |
	sed -e '1,$s/&#0;//g' | html_unquote.py > "$tmp_meta"

for key in 'Title' 'Author' 'Subject' 'Keywords'; do
	if ! grep "$key" "$tmp_meta" > /dev/null; then
		echo "${info_key}$key" >> "$tmp_meta"
		echo "$info_val" >> "$tmp_meta"
	fi
done

evince "$pdf_in" &

cp "$tmp_meta" "$tmp_meta2"

vim "$tmp_meta"

diff "$tmp_meta" "$tmp_meta2" > /dev/null && exit 0

echo -n "Update the metadata [y/N]: "
read -r res

if [ "$(echo "$res" | tr Y y)" = "y" ]; then
	pdftk "$pdf_in" update_info "$tmp_meta" output "$tmp_out"
	mv "$pdf_in" ~/tmp/
	mv "$tmp_out" "$pdf_in"
	evince "$pdf_in"
	pdfinfo "$pdf_in"
fi
