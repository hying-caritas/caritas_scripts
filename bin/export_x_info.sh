#!/usr/bin/env bash
# Export the dbus session address on startup so it can be used by cron
# Based on: http://jason.the-graham.com/2011/01/16/gnome_keyring_with_msmtp_imapfilter_offlineimap/

: > "$HOME/.Xdbus"
chmod 600 "$HOME/.Xdbus"

export_var()
{
	var=$1
	echo "export $var=${!var}" >> "$HOME/.Xdbus"
}

export_var DISPLAY
export_var DBUS_SESSION_BUS_ADDRESS
