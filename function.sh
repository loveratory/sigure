#!/bin/bash
function line () {
    echo $1 | grep '^[0-9]*$' >& /dev/null
    if [ $? -eq 0 ]; then
        local line
        local i=3
        while [ $i -le $1 ]
        do
            line="${line}-"
            i=`expr $i + 1`
        done
        if [ "$mute" != true ]; then
            printf " $line \n"
        fi
    else
        show "invaild argument" 1>&2
    fi
}

function show () {
    if [ "$mute" != true ]; then
        echo "$@"
    fi
}

function color() {
    local red=31
    local green=32
    local yello=33
    local blue=34
    local color=$1
    show -e "\033[${!color}m${2}\033[m" ${3}
}

function git_info () {
    if [ -d "$1/.git" ]; then
        git_ref=$(sed "s/.*: //g" "$1/.git/HEAD")
        git_branch=${git_ref##*/}
        git_commit=$(cat "$1/.git/${git_ref}")
    fi
}

function git_update () {
    if [ -d "$1/.git" ]; then
        color green "Welcome to sigure updator!"
        line 26
        git_info $1
        local git_commit_older=${git_commit}
        color green "start updating..."
        cd $1
        git pull >& /dev/null
        if [ $? -ne 0 ]; then
            color red "E: git update failed." 1>&2
            cd $2
            return 1
        fi
        git info $1
        if [ ${git_commit_older} != ${git_commit} ]; then
            color green "I: update ${git_commit_older} to ${git_commit}"
        else
            color green "I: Already up-to-date."
        fi
        cd $2
        return 0
    else
        color red "E: not git directory." 1>&2
        return 1
    fi
}

function usage () {
    show "usage: sigure [-d dir] [-h] [-m] [-u] [-x]" ${1}
    show "-d: target directory" ${1}
    show "-h: show help" ${1}
    show "-m: mute mode" ${1}
    show "-u: git updator." ${1}
    show "-x: direct start-up" ${1}
    show -e "    do not use screen" ${1}
}