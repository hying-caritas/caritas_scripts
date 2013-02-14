#!/bin/bash
#TAGS: ebook

set -e

source caritas_functions.sh

BAK_DIR=

load_config

cfg BAK_DIR $HOME/tmp

usage()
{
    echo "$(basename $0) <pdf>"
}

clean()
{
    rm -rf $tmp_meta1 $tmp_meta2
}

[ $# -eq 1 ] || usage || exit 1

djvu_in="$1"

trap clean EXIT

tmp_meta1=$(temp_file djvu_meta_)
tmp_meta2=$(temp_file djvu_meta_)

djvused -e print-meta "$djvu_in" | djvu_unquote.py > $tmp_meta1

for key in 'Title' 'Author' 'Subject' 'Keywords'; do
    if ! grep $key $tmp_meta1 > /dev/null; then
        echo -e "$key\t\"\"" >> $tmp_meta1
    fi
done

djview "$djvu_in" &

cp $tmp_meta1 $tmp_meta2

vim $tmp_meta1

diff $tmp_meta1 $tmp_meta2 > /dev/null && exit 0

echo -n "Update the metadata [y/N]: "
read res

if [ "$(echo "$res" | tr Y y)" = "y" ]; then
    djvused -s -e "set-meta $tmp_meta1" "$djvu_in"
    djview "$djvu_in"
    cp "$djvu_in" $BAK_DIR
    djvused -e print-meta "$djvu_in" | djvu_unquote.py
fi
