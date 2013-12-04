#!/bin/bash

source caritas_functions.sh

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

load_config

cfg WORK_USE_SOCKS_PROXY 1
cfg HOME_USE_SOCKS_PROXY 1
cfg AUTOPROXY_PAC "$HOME/.config/autoproxy.pac"

prog=$(basename $0)

usage()
{
	echo "Usage: $prog <home|work>"
}

if [ $# -ne 1 ]; then
	usage
	exit -1
fi

tnet=$1
if [ $tnet != "home" -a $tnet != "work" ]; then
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

setup_autoproxy_pac()
{
	local proxy_host="$1"
	local AUTOPROXY_PAC_BAK=$AUTOPROXY_PAC.bak

	if [ -z "$proxy_host" ] && [ -f $AUTOPROXY_PAC ]; then
		mv $AUTOPROXY_PAC $AUTOPROXY_PAC_BAK
	elif [ -n "$proxy_host" ] && [ -f $AUTOPROXY_PAC_BAK ]; then
		mv $AUTOPROXY_PAC_BAK $AUTOPROXY_PAC
	fi
}

setup_proxy()
{
	local proxy_host="$1"
	local proxy_port="$2"
	local internal_domains="$3"
	[ $# -ne 3 ] && die_invalid

	setup_apt_proxy $proxy_host $proxy_port
	setup_autoproxy_pac $proxy_host $proxy_port

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
