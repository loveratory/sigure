#!/bin/bash
# reset variables
unset verbose
unset file_src
unset dir_src
unset dir_run

# assign paths
file_src=$(readlink -f $0)
dir_src=${file_src%/*}
dir_run=$(pwd)

# import functions
source "${dir_src}/function.sh"

# process arguments
while getopts d:hvx argument
do
    case $argument in
        d) dir_tgt="$OPTARG" ;;
        h) unset verbose
           usage
           exit 0 ;;
        v) verbose=true ;;
        x) direct=true ;;
    esac
done

# assign git information
if [ -d "${dir_src}/.git" ]; then
    git_ref=$(sed "s/.*: //g" "${dir_src}/.git/HEAD")
    git_branch=${git_ref##*/}
    git_commit=$(cat "${dir_src}/.git/${git_ref}")
fi

# welcome message
show "Welcome to sigure! <${git_branch}>"
show "commit: ${git_commit}"
line 48

# check whether the target directory exits
if [ "${dir_tgt}" = "" ]; then
    color red "E: unspecified target directory." 1>&2
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
    source "${dir_src}/build.sh"
    exit $?
else
    type screen >& /dev/null
    if [ $? -ne 0 ]; then
        color red "E: screen not installed." 1>&2
        show "you don't need start with screen, use -x option." 1>&2
        exit 1
    fi
    screen "${dir_src}/build.sh" -d "${dir_tgt_full}" -x "${dir_src}" -v ${verbose}
    exit 0
fi