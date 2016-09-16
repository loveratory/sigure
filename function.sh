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
        show "invaild argument"
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

function git () {
    if [ -d "$1/.git" ]; then
        git_ref=$(sed "s/.*: //g" "$1/.git/HEAD")
        git_branch=${git_ref##*/}
        git_commit=$(cat "$1/.git/${git_ref}")
    fi
}

function usage () {
    show "usage: sigure [-d dir] [-h] [-m] [-x]" ${1}
    show "-d: target directory" ${1}
    show "-h: show help" ${1}
    show "-m: mute mode" ${1}
    show "-x: direct start-up" ${1}
    show -e "    do not use screen" ${1}
}