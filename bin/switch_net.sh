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

load_config

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

setup_proxy()
{
	local proxy_host="$1"
	local proxy_port="$2"
	local internal_domains="$3"
	[ $# -ne 3 ] && die_invalid

	if [ -z "$proxy_host" ]; then
		sudo rm -f /etc/apt/apt.conf.avail/99proxy
		gsettings set org.gnome.system.proxy mode none
		gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8']"
		return
	fi
	echo "Acquire::http::Proxy \"http://$proxy_host/$proxy_port\";
Acquire::ftp::Proxy \"http://$proxy_host/$proxy_port\";" |
		sudo_outf /etc/apt/apt.conf.avail/99proxy
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

HOSTS_PREFIX="# ==== CARITAS SWITCH_NET BEGIN ===="
HOSTS_POSTFIX="# ==== CARITAS SWITCH_NET END ===="

setup_hosts()
{
	local hosts="$1"
	[ $# -ne 1 ] && die_invalid

	sudo sed -ie "/$HOSTS_PREFIX/,/$HOSTS_POSTFIX/d" /etc/hosts
	if [ -z "$hosts" ]; then
		return
	fi
	echo "$HOSTS_PREFIX
$hosts
$HOSTS_POSTFIX" | sudo_outf -a /etc/hosts
}

if [ "$tnet" == "work" ]; then
	setup_proxy "$WORK_HTTP_PROXY_HOST" "$WORK_HTTP_PROXY_PORT" "$WORK_INTERNAL_DOMAINS"
	setup_hosts "$WORK_HOSTS"
else
	setup_proxy "$HOME_HTTP_PROXY_HOST" "$HOME_HTTP_PROXY_PORT" "$HOME_INTERNAL_DOMAINS"
	setup_hosts "$HOME_HOSTS"
fi
