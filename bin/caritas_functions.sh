
nr_cpu=$(grep -c processor /proc/cpuinfo)

die()
{
	echo "die: $@"
	exit 231
}

die_invalid()
{
	die "Invalid parameter: $@"
}

cfg()
{
	local var="$1"
	local val="$2"
	[ $# -ne 2 ] && die "Invalid configuration item: cfg $var $val"
	eval 	"declare -g $var;
		 if [ -z \"\$$var\" ]; then
		 	$var=\"$val\";
		 fi"
}

load_config()
{
	for config_dir in $CARITAS_SCRIPTS_CONFIG ./.caritas_scripts_config $HOME/.config/caritas_scripts; do
		config_file=$(basename $0)
		config_path="$config_dir/$config_file"
		if [ -f "$config_path" ]; then
			source "$config_path"
			break
		fi
	done
}

term_chg_title()
{
	local title="$1"
	[ -z "$title" ] && die_invalid
	export PS1="$PS1\[\e]0;$title\a\]"
}

normalize_path()
{
	local path="$1"
	(cd "$path"; pwd)
}

prepend_PATH()
{
	local dir="$1"
	dir=$(normalize_path "$dir")
	if ! echo $PATH | tr ':' '\n' | grep -q "^$dir\$"; then
		export PATH=$dir:$PATH
	fi
}

temp_file()
{
	temp_file_seq=$((temp_file_n+1))
	local prefix="${1:-$0}"
	if which tempfile > /dev/null; then
		tempfile --prefix="$prefix"
	else
		echo "/tmp/$prefix-$$-$temp_file_seq"
	fi
}

lookup()
{
	nslookup "$1" | grep Address | tail -1 | cut -d ' ' -f 2
}
