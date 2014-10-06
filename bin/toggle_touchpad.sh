#!/bin/bash

prev=$(gsettings get org.gnome.settings-daemon.peripherals.touchpad touchpad-enabled)

val=true
[[ $prev = true ]] && val=false

gsettings set org.gnome.settings-daemon.peripherals.touchpad touchpad-enabled $val
