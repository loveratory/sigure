#!/bin/bash
unset verbose
unset file_src
unset dir_src
unset dir_run

file_src=$(readlink -f $0)
dir_src=${file_src%/*}
dir_run=$(pwd)

source "${dir_src}/function.sh"

while getopts vhx argument
do
    case $argument in
        h) unset verbose
           usage
           exit 0 ;;
        v) verbose=true ;;
        x) direct=true ;;
    esac
done

if [ -d "${dir_src}/.git" ]; then
    git_ref=$(sed "s/.*: //g" "${dir_src}/.git/HEAD")
    git_branch=${git_ref##*/}
    git_commit=$(cat "${dir_src}/.git/${git_ref}")
fi

show "Welcome to sigure! <${git_branch}>"
show "commit: ${git_commit}"
line 48

if [ $direct = true ]; then
    source "${dir_src}/build.sh" -d "${dir_run}" -x "${dir_src}" -v ${verbose}
    exit $?
else
    type screen >& /dev/null
    if [ $? -ne 0 ]; then
        color red "E: screen not installed." 1>&2
        show "you don't need start with screen, use -x option." 1>&2
        exit 1
    fi
    screen "${dir_src}/build.sh" -d "${dir_run}" -x "${dir_src}" -v ${verbose}
    exit 0
fi