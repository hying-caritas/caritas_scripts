#!/usr/bin/env bash
#TAGS: kernel

set -e

source caritas_functions.sh

dl_exe=
dl_dat=

site=
path=

net_dev=
exe_dest=

load_config

cfg dl_dat "modules.tar.gz bzImage"
cfg net_dev eth0
cfg exe_dest usr/local/bin

[ -z "$site" ] && die "Please configure site to download kernel and executables"

site=$(lookup $site)

install_kernel()
{
	echo "$dl_dat" | grep -q bzImage || return
	mv bzImage "vmlinuz-$kver"
	sudo cp "vmlinuz-$kver" /boot/
	sudo ln -sf "vmlinuz-$kver" /boot/vmlinuz
}

install_modules()
{
	echo "$dl_dat" | grep -q modules.tar.gz || return
	kver="$(tar -tzf modules.tar.gz | grep '/lib/modules/.\\+' | tail |
		sed -e 's?lib/modules/\\([^/]*\\)/.*?\\1?')"
	if [ -z "$kver" ] || echo "$kver" | grep -q '[0-9]$'; then
		echo "Invalid kernel version: $kver"
		exit 1
	fi
	cwd="$(pwd)"
	echo "kernel version: $kver"
	(
		cd /;
		rm -rf "/lib/modules/$kver";
		sudo tar -xzf "$cwd/modules.tar.gz";
		sudo depmod "$kver";
	)
}

install_vmlinux()
{
	echo "$dl_dat" | grep -q vmlinux || return
	mkdir -p "$(readlink "/lib/modules/$kver/build")"
	sudo cp vmlinux "/lib/modules/$kver/build"
}

ifup "$net_dev" || true

[ -x rmmod.sh ] && ./rmmod.sh

for f in $dl_exe $dl_dat; do
	rm -rf "$f"
	wget "http://$site/$path/$f"
done

for f in $dl_exe; do
	sudo install -m 0755 "$f" "$exe_dest"
done

install_modules
install_kernel
install_vmlinux
