#!/bin/bash
unset scr_main
unset dir_src
unset dir_run

# assign paths
scr_main=$(readlink -f $0)
dir_src=${scr_main%/*}
dir_work=$(pwd)

# import functions
source "${dir_src}/function.sh"

# reset variables
source "${dir_src}/reset.sh"

# assign git information
git_info "${dir_src}"

# welcome message
center "Welcome to sigure! <${git_branch}>" 48
show "commit: ${git_commit}"
line $len_line

# process arguments
while getopts :d:hmux argument
do
    case $argument in
        d) dir_tgt="$OPTARG" ;;
        h) usage
           header 0 ;;
        m) mute=true ;;
        u) git_update "${dir_src}" "${dir_work}"
           header $? ;;
        x) direct=true ;;
        \?) usage
            header 1;;
    esac
done

# check whether the target directory exist
if [ "${dir_tgt}" = "" ]; then
    color red "E: target directory is unspecified." 1>&2
    finish=true
elif [ -d "${dir_run}/${dir_tgt}" ]; then
    dir_tgt_full="${dir_run}/${dir_tgt}"
elif [ -d "${dir_tgt}" ]; then
    dir_tgt_full=$(readlink -f "${dir_tgt}")
else
    color red "E: target directory does not exist." 1>&2
    finish=true
fi

# can Finish
if [ "$finish" != true ]; then
    header 1
fi

# kick-start build
if [ "$direct" = true ]; then
    bash "${dir_src}/build.sh" "$@" -D "${dir_tgt_full}" -S "${dir_src}"
    header $?
else
    type screen >& /dev/null
    if [ $? -ne 0 ]; then
        color red "E: screen not installed." 1>&2
        show "you don't need start with screen, use -x option." 1>&2
        header 1
    fi
    screen bash "${dir_src}/build.sh" "$@" -D "${dir_tgt_full}" -S "${dir_src}"
    header 0
fi