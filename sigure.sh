#!/bin/bash
unset scr_main
unset dir_src
unset dir_run

# assign paths
scr_main=$(readlink -f $0)
dir_src=${scr_main%/*}
dir_run=$(pwd)

# import functions
source "${dir_src}/function.sh"

# reset variables
source "${dir_src}/reset.sh"

# process arguments
while getopts d:hmx argument
do
    case $argument in
        d) dir_tgt="$OPTARG" ;;
        h) usage
           exit 0 ;;
        m) mute=true ;;
        x) direct=true ;;
    esac
done

# assign git information
git "${dir_src}"

# welcome message
show "Welcome to sigure! <${git_branch}>"
show "commit: ${git_commit}"
line 48

# check whether the target directory exits
if [ "${dir_tgt}" = "" ]; then
    color red "E: target directory is unspecified." 1>&2
    exit 1
elif [ -d "${dir_run}/${dir_tgt}" ]; then
    dir_tgt_full="${dir_run}/${dir_tgt}"
elif [ -d "${dir_tgt}" ]; then
    dir_tgt_full=$(readlink -f "${dir_tgt}")
else
    color red "E: target directory does not exist." 1>&2
    exit 1
fi

# kick-start build
if [ "$direct" = true ]; then
    bash "${dir_src}/build.sh" -d "${dir_tgt_full}" -x "${dir_src}"
    exit $?
else
    type screen >& /dev/null
    if [ $? -ne 0 ]; then
        color red "E: screen not installed." 1>&2
        show "you don't need start with screen, use -x option." 1>&2
        exit 1
    fi
    screen "${dir_src}/build.sh" -d "${dir_tgt_full}" -x "${dir_src}"
    exit 0
fi