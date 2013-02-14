#!/bin/bash

echo $0

source caritas_functions.sh
load_config
cfg abc cde
echo $abc
echo $bcd
echo $BASH_SOURCE
