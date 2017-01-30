#!/bin/sh

set -e

beep_sound_file=/usr/share/sounds/freedesktop/stereo/complete.oga

beep()
{
	if which mplayer > /dev/null && [ -f $beep_sound_file ]; then
		mplayer -nolirc -really-quiet $beep_sound_file
	fi
}

stop_record()
{
	killall parec
}

stop_record
beep
