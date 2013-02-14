alias chm_extract="chm2pdf --extract-only"

# For evolution on wide screen machine
alias eecalendar="evolution --express -c calendar"
alias eecontacts="evolution --express -c contacts"
alias eemail="evolution --express -c mail"

alias emacsnd="emacs --no-desktop"
alias emacsnx="emacs -nw"

alias muse_pub_file="emacs -q -batch -l ~/.emacs -f muse-publish-file"
alias muse_pub_proj="emacs -q -batch -l ~/.emacs -f muse-project-batch-publish"

alias dos2unix="sed -ie 's/\r//'"
alias unix2dos="sed -ie 's/$/\r/'"

alias wkhtmltopdf_kindle_dxg="wkhtmltopdf-amd64 --page-height 203mm --page-width 140mm -B 3mm -L 3mm -R 3mm -T 3mm -g"
alias wkhtmltopdf_nook_table="wkhtmltopdf-amd64 --page-height 204mm --page-width 120mm -B 1mm -L 1mm -R 1mm -T 1mm"
