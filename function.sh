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
        printf " $line \n"
    else
        show "invaild argument"
    fi
}

function show () {
    if [ "$verbose" != true ]; then
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

function usage () {
    show "usage: sigure [-h] [-v] [-x]" ${1}
    show "-h: show help" ${1}
    show "-v: verbose mode" ${1}
    show "-x: direct start-up" ${1}
    show -e "    do not use screen" ${1}
}