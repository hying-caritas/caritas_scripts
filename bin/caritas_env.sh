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
