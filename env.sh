__SD=$(dirname $BASH_SOURCE)
SD=$(cd $__SD; pwd)

source $SD/bin/caritas_functions.sh
prepend_PATH $SD/bin
prepend_PYTHONPATH $SD/bin
prepend_PYTHONPATH $SD/lib
source $SD/bin/caritas_aliases.sh
