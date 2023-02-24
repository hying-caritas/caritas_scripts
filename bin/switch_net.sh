#!/usr/bin/env bash

source caritas_functions.sh

CONFIG_DIR=
WORK_HTTP_PROXY_HOST=
WORK_HTTP_PROXY_PORT=
HOME_HTTP_PROXY_HOST=
HOME_HTTP_PROXY_PORT=
WORK_HOSTS=
HOME_HOSTS=
WORK_INTERNAL_DOMAINS=
HOME_INTERNAL_DOMAINS=
WORK_USE_SOCKS_PROXY=
HOME_USE_SOCKS_PROXY=
PROXY_CONFIG_FILES=

load_config

cfg CONFIG_DIR "$HOME/.config/switch_net"
cfg WORK_USE_SOCKS_PROXY 1
cfg HOME_USE_SOCKS_PROXY 1

prog=$(basename "$0")

usage()
{
	echo "Usage: $prog <home|work>"
}

tnet=$1

if [ "$tnet" = "-i" ]; then
	echo -n "switch_net [w|H]: "
	read -r tnet
	if [ "$tnet" = w ]; then
		tnet=work
	else
		tnet=home
	fi
fi

if [ "$tnet" = "home" ]; then
	rm -f "$CONFIG_DIR/work"
	touch "$CONFIG_DIR/home"
elif [ "$tnet" = "work" ]; then
	rm -f "$CONFIG_DIR/home"
	touch "$CONFIG_DIR/work"
else
	usage
	exit -1
fi

setup_apt_proxy()
{
	local proxy_host="$1"
	local proxy_port="$2"

	[ -d /etc/apt ] || return

	if [ -z "$proxy_host" ]; then
		sudo rm -f /etc/apt/apt.conf.d/99proxy
		return
	fi

	echo "Acquire::http::Proxy \"http://$proxy_host:$proxy_port\";
Acquire::ftp::Proxy \"http://$proxy_host:$proxy_port\";" |
		sudo_outf /etc/apt/apt.conf.d/99proxy
}

setup_proxy_config()
{
	for config_file in $PROXY_CONFIG_FILES; do
		if [ -f $config_file.$tnet ]; then
			cp $config_file.$tnet $config_file
		elif [ -f $config_file ]; then
			mv $config_file $config_file.bak
		fi
	done
}

setup_proxy()
{
	local proxy_host="$1"
	local proxy_port="$2"
	local internal_domains="$3"
	[ $# -ne 3 ] && die_invalid "$@"

	setup_apt_proxy "$proxy_host" "$proxy_port"

	if [ -z "$proxy_host" ]; then
		gsettings set org.gnome.system.proxy mode none
		gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8']"
		return
	fi
	gsettings set org.gnome.system.proxy mode manual
	for proto in http https ftp; do
		gsettings set "org.gnome.system.proxy.$proto" host "$proxy_host"
		gsettings set "org.gnome.system.proxy.$proto" port "$proxy_port"
	done
	if [ -n "$internal_domains" ]; then
		gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8', $internal_domains]"
	else
		gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8']"
	fi
}

SWITCH_NET_BEGIN="# ==== CARITAS SWITCH_NET BEGIN ===="
SWITCH_NET_END="# ==== CARITAS SWITCH_NET END ===="

setup_hosts()
{
	local hosts="$1"
	[ $# -ne 1 ] && die_invalid "$@"

	sudo sed -ie "/$SWITCH_NET_BEGIN/,/$SWITCH_NET_END/d" /etc/hosts
	if [ -z "$hosts" ]; then
		return
	fi
	echo "$SWITCH_NET_BEGIN
$hosts
$SWITCH_NET_END" | sudo_outf -a /etc/hosts
}

setup_tsocks()
{
	local use_proxy="$1"
	[ $# -ne 1 ] && die_invalid "$@"

	tsocks_conf1=/etc/tsocks.conf
	tsocks_conf2=/etc/socks/tsocks.conf
	[ -f $tsocks_conf1 ] && tsocks_conf=$tsocks_conf1
	[ -f $tsocks_conf2 ] && tsocks_conf=$tsocks_conf2
	if [ -z $tsocks_conf ]; then
		return
	fi

	sudo sed -ie "/$SWITCH_NET_BEGIN/,/$SWITCH_NET_END/d" $tsocks_conf

	if ((use_proxy)); then
		return
	fi
	echo "$SWITCH_NET_BEGIN
local = 0.0.0.0/0.0.0.0
$SWITCH_NET_END" | sudo_outf -a $tsocks_conf
}

if [ "$tnet" == "work" ]; then
	setup_proxy_config
	setup_proxy "$WORK_HTTP_PROXY_HOST" "$WORK_HTTP_PROXY_PORT" "$WORK_INTERNAL_DOMAINS"
	setup_hosts "$WORK_HOSTS"
	setup_tsocks "$WORK_USE_SOCKS_PROXY"
else
	setup_proxy_config
	setup_proxy "$HOME_HTTP_PROXY_HOST" "$HOME_HTTP_PROXY_PORT" "$HOME_INTERNAL_DOMAINS"
	setup_hosts "$HOME_HOSTS"
	setup_tsocks "$HOME_USE_SOCKS_PROXY"
fi

emacsclient -e "(switch-network)" > /dev/null
systemctl --user restart gvfs-daemon
