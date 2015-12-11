chm_extract()
{
	chm2pdf --extract-only "$@"
}

# For evolution on wide screen machine
eecalendar()
{
	evolution --express -c calendar "$@"
}

eecontacts()
{
	evolution --express -c contacts "$@"
}

eemail()
{
	evolution --express -c mail "$@"
}

emacsnd()
{
	emacs --no-desktop "$@"
}

emacsnx()
{
	emacs -nw "$@"
}

muse_pub_file()
{
	emacs -q -batch -l ~/.emacs -f muse-publish-file "$@"
}

muse_pub_proj()
{
	emacs -q -batch -l ~/.emacs -f muse-project-batch-publish "$@"
}

dos2unix()
{
	sed -ie 's/\r//' "$@"
}

unix2dos()
{
	sed -ie 's/$/\r/' "$@"
}

wkhtmltopdf_kindle_dxg()
{
	wkhtmltopdf-amd64 --page-height 203mm --page-width 140mm -B 3mm -L 3mm -R 3mm -T 3mm -g "$@"
}

wkhtmltopdf_nook_table()
{
	wkhtmltopdf-amd64 --page-height 204mm --page-width 120mm -B 1mm -L 1mm -R 1mm -T 1mm "$@"
}

pmake()
{
	make -j $((2*$nr_cpu)) "$@" 2>&1 | tee pmake.log
}

bgrun()
{
	nohup "$@" &> /dev/null &
}

man()
{
	if [[ $INSIDE_EMACS ]]; then
		eshell man "$@"
	else
		command man "$@"
	fi
}

info()
{
	if [[ $INSIDE_EMACS ]]; then
		eshell info "$@"
	else
		command info "$@"
	fi
}

make()
{
	if [[ $INSIDE_EMACS && -t 0 && -t 1 && -t 2 ]]; then
		eshell info "$@"
	else
		command info "$@"
	fi
}

grep()
{
	if [[ $INSIDE_EMACS && -t 0 && -t 1 && -t 2 ]]; then
		eshell grep "$@"
	else
		command grep "$@"
	fi
}

diff()
{
	if [[ $INSIDE_EMACS && -t 0 && -t 1 && -t 2 ]]; then
		eshell diff "$@"
	else
		command diff "$@"
	fi
}

find-file()
{
	eshell find-file "$@"
}

find-file-other-window()
{
	eshell find-file-other-window "$@"
}

view-file()
{
	eshell view-file "$@"
}

view-file-other-window()
{
	eshell view-file-other-window
}

dired()
{
	[ $# -eq 0 ] && set .
	eshell dired "$@"
}

dired-other-window()
{
	[ $# -eq 0 ] && set .
	eshell dired-other-window "$@"
}

find-dired()
{
	dir=${1:-.}
	shift
	emax -e "(find-dired \"$dir\" \"$*\")"
}

proced()
{
	eshell proced
}

magit()
{
	eshell magit
}

apropos-command()
{
	eshell apropos-command "$@"
}
