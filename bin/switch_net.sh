#!/bin/bash

source caritas_functions.sh

CONFIG_DIR=
WORK_HTTP_PROXY_HOST=
WORK_HTTP_PROXY_PORT=
HOME_HTTP_PROXY_HOST=
HOME_HTTP_PROXY_PORT=
WORK_HOSTS=
HOME_HOSTS=
WORK_INTERNAL_DOMAINS=
HOME_INTERNAL_DOMAINs=
WORK_USE_SOCKS_PROXY=
HOME_USE_SOCKS_PROXY=
AUTOPROXY_PAC=
QUICKLISP_PROXY_CONF=

load_config

cfg CONFIG_DIR "$HOME/.config/switch_net"
cfg WORK_USE_SOCKS_PROXY 1
cfg HOME_USE_SOCKS_PROXY 1
cfg AUTOPROXY_PAC "$CONFIG_DIR/autoproxy.pac"
cfg QUICKLISP_PROXY_CONF "$HOME/quicklisp/config/proxy-url.txt"

prog=$(basename $0)

usage()
{
	echo "Usage: $prog <home|work>"
}

tnet=$1
if [ "$tnet" = "home" ]; then
	rm -f "$CONFIG_DIR/work"
	touch "$CONFIG_DIR/home"
elif [ "$tnet" = "work" ]; then
	rm -f "$CONFIG_DIR/home"
	touch "$CONFIG_DIR/work"
elif [ "$tnet" = "-i" ]; then
	echo -n "switch_net [w|H]: "
	read tnet
	if [ "$tnet" = w ]; then
		tnet=work
	else
		tnet=home
	fi
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
	local proxy_host="$1"
	local proxy_port="$2"
	local config_file="$3"
	local config_file_bak=$config_file.bak

	if [ -z "$proxy_host" ] && [ -f $config_file ]; then
		mv $config_file $config_file_bak
	elif [ -n "$proxy_host" ] && [ -f $config_file_bak ]; then
		mv $config_file_bak $config_file
	fi
}

setup_proxy()
{
	local proxy_host="$1"
	local proxy_port="$2"
	local internal_domains="$3"
	[ $# -ne 3 ] && die_invalid

	setup_apt_proxy $proxy_host $proxy_port
	for config_file in $AUTOPROXY_PAC $QUICKLISP_PROXY_CONF; do
		setup_proxy_config "$proxy_host" "$proxy_port" "$config_file"
	done

	if [ -z "$proxy_host" ]; then
		gsettings set org.gnome.system.proxy mode none
		gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8']"
		return
	fi
	gsettings set org.gnome.system.proxy mode manual
	for proto in http https ftp; do
		gsettings set org.gnome.system.proxy.$proto host "$proxy_host"
		gsettings set org.gnome.system.proxy.$proto port "$proxy_port"
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
	[ $# -ne 1 ] && die_invalid

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
	[ $# -ne 1 ] && die_invalid

	if ! [ -f /etc/tsocks.conf ]; then
		return
	fi

	sudo sed -ie "/$SWITCH_NET_BEGIN/,/$SWITCH_NET_END/d" /etc/tsocks.conf

	if (($use_proxy)); then
		return
	fi
	echo "$SWITCH_NET_BEGIN
local = 0.0.0.0/0.0.0.0
$SWITCH_NET_END" | sudo_outf -a /etc/tsocks.conf
}

if [ "$tnet" == "work" ]; then
	setup_proxy "$WORK_HTTP_PROXY_HOST" "$WORK_HTTP_PROXY_PORT" "$WORK_INTERNAL_DOMAINS"
	setup_hosts "$WORK_HOSTS"
	setup_tsocks "$WORK_USE_SOCKS_PROXY"
else
	setup_proxy "$HOME_HTTP_PROXY_HOST" "$HOME_HTTP_PROXY_PORT" "$HOME_INTERNAL_DOMAINS"
	setup_hosts "$HOME_HOSTS"
	setup_tsocks "$HOME_USE_SOCKS_PROXY"
fi
