#!/bin/bash
#TAGS: kernel

set -e

#sudo kexec -l /boot/vmlinuz --append="$(cat /proc/cmdline) initcall_debug"
sudo kexec -l /boot/vmlinuz --append="$(cat /proc/cmdline) $*"
sudo kexec -e
