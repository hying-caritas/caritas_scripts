#!/usr/bin/env bash
#TAGS: kernel

set -e

source caritas_functions.sh

KVM_ROOT=
KVER=
KVM_WORK_DIR=

load_config

( [ -z "$KVM_ROOT" ] || [ -z "$KVER" ] || [ -z "$KVM_WORK_DIR" ] ) &&
	die "Please provide necessary configurations"

make "-j$nr_cpu"
sudo make modules_install "INSTALL_MOD_PATH=$KVM_ROOT"
sudo depmod -b "$KVM_ROOT" "$KVER"
if [ -n "$KVM_WORK_DIR" ]; then
	cp arch/x86/boot/bzImage "$KVM_WORK_DIR/vmlinuz"
fi
