#!/usr/bin/env bash

set -e

source caritas_functions.sh

RECORDS_DIR=

load_config

cfg RECORDS_DIR "$HOME/records"

prefix="$1"

fake_sink="caritas-record"
beep_sound_file=/usr/share/sounds/freedesktop/stereo/message.oga

if ! echo "$prefix" | grep -q "^/"; then
	mkdir -p $RECORDS_DIR
	prefix="$RECORDS_DIR/$prefix"
fi
curr_time=$(date +%Y_%m_%d_%H_%M_%S)
ofn="${prefix}_${curr_time}.ogg"

notify()
{
	if which mplayer > /dev/null && [ -f $beep_sound_file ]; then
		mplayer -nolirc -really-quiet $beep_sound_file
	fi
	gnotify.py -a "pa record" "recording start"
}

setup_record()
{
	if pactl list sources | grep -q $fake_sink.monitor; then
		return 0
	fi
	pactl load-module module-null-sink sink_name="$fake_sink" > /dev/null
	all_src=$(pactl list sources | grep -v $fake_sink\.monitor | sed -n '1,$s/^\tName: \(.*\)/\1/p')
	for src in $all_src; do
		pactl load-module module-loopback source="$src" sink="$fake_sink" > /dev/null
	done
}

start_record()
{
	if pgrep parec > /dev/null; then
		echo "already recording"
		return 1
	fi
	parec -d "$fake_sink.monitor" | oggenc -Q -o "$ofn" --raw - &
}

setup_record
if start_record; then
	notify
fi
