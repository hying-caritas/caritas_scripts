#!/bin/bash

set -e

cd /sys/devices/platform/i8042/serio1
echo 1 | sudo_outf press_to_select
echo 200 | sudo_outf speed
echo 200 | sudo_outf sensitivity
