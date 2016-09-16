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

# process arguments
while getopts :d:hmux argument
do
    case $argument in
        d) dir_tgt="$OPTARG" ;;
        h) help=true ;;
        m) mute=true ;;
        u) update=true ;;
        x) direct=true ;;
        \?) help=true ;;
    esac
done

# assign git information
git_info "${dir_src}"

# welcome message
center "Welcome to sigure! <${git_branch}>" $len_line
center "commit: ${git_commit}" $len_line
line $len_line

# kick-start help

if [ "$help" = true ]; then
    usage
    footer 0
fi

# kick-start updator
if [ "$update" = true ]; then
    git_update "${dir_src}" "${dir_work}"
    footer $?
fi

# check whether the target directory exist
if [ "${dir_tgt}" = "" ]; then
    error "* E: target directory is unspecified."
    finish=true
elif [ -d "${dir_run}/${dir_tgt}" ]; then
    dir_tgt_full="${dir_run}/${dir_tgt}"
elif [ -d "${dir_tgt}" ]; then
    dir_tgt_full=$(readlink -f "${dir_tgt}")
else
    error "* E: target directory does not exist."
    finish=true
fi

# can Finish
if [ "$finish" != true ]; then
    footer 1
fi

# kick-start build
if [ "$direct" = true ]; then
    bash "${dir_src}/build.sh" "$@" -D "${dir_tgt_full}" -S "${dir_src}"
    footer $?
else
    type screen >& /dev/null
    if [ $? -ne 0 ]; then
        error "* E: screen not installed."
        show "* you don't need start with screen, use -x option." 1>&2
        footer 1
    fi
    screen bash "${dir_src}/build.sh" "$@" -D "${dir_tgt_full}" -S "${dir_src}"
    footer 0
fi