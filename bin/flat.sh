#!/bin/sh
#TAGS: onkyo, mp3

set -e

find -type f -exec flat_file_name.sh \{\} \;

find -depth -type d -exec flat_rm_dir.sh \{\} \;
