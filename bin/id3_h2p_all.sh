#!/bin/bash
#TAGS: onkyo, mp3

find . -type f -name '*.mp3' -o -name '*.MP3' -exec id3_h2p.py \{\} \;
