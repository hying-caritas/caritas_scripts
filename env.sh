__SD=$(dirname $BASH_SOURCE)
SD=$(cd $__SD; pwd)

source $SD/bin/caritas_functions.sh
prepend_PATH $SD/bin
source $SD/bin/caritas_aliases.sh
