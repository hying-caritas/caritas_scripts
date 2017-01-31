#!/bin/bash
#TAGS: kernel

set -e

source caritas_functions.sh

DIST_DIR=
WORK_DIR=

load_config

cfg WORK_DIR=".."

[ -z "$DIST_DIR" ] && die "Please configure DIST_DIR"

make ARCH=i386 -j$nr_cpu
rm -rf $WORK_DIR/lib
make ARCH=i386 modules_install INSTALL_MOD_PATH=$WORK_DIR
cp arch/x86/boot/bzImage $WORK_DIR
cp vmlinux $WORK_DIR
cd $WORK_DIR
tar -czf modules.tar.gz lib
sudo mv bzImage $DIST_DIR
sudo mv vmlinux $DIST_DIR
sudo mv modules.tar.gz $DIST_DIR
