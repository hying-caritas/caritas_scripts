#!/usr/bin/env bash
#TAGS: kernel

source caritas_functions.sh

srv_port=

load_config

cfg srv_port 6666

nc -ul -p $srv_port
