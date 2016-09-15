#!/bin/bash
unset verbose
unset file_src
unset dir_src
unset dir_run

file_src=$(readlink -f $0)
dir_src=${file_src%/*}
dir_run=$(pwd)

source ${dir_src}/function.sh

# get argument
while getopts vh argument
do
    case $argument in
        h) unset verbose
           usage
           exit 0 ;;
        v) verbose=true ;;
    esac
done

git_ref=$(sed "s/.*: //g" ${dir_src}/.git/HEAD)
git_branch=${git_ref##*/}
git_commit=$(cat ${dir_src}/.git/${git_ref})

show "Welcome to sigure! <${git_branch}>"
show "commit: ${git_commit}"
line 48