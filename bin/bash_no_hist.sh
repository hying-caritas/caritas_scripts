#!/bin/sh

chg_title()
{
	echo -ne "\033]0;""$1""\007"
}

export TERM=vt100
export HISTFILE=/tmp/.bash_no_hist$$

clean()
{
	echo clean
	rm -f $HISTFILE
}

trap clean EXIT

chg_title "no history"
bash -i
