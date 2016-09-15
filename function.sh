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
        show " $line "
    else
        echo "invaild argument"
    fi
}

function show () {
    if [ "$verbose" != true ]; then
        printf "$1\n" $2
    fi
}

function usage () {
    show "usage: sigure [-h] [-v]" ${1}
    show "-h: show help" ${1}
    show "-v: verbose mode" ${1}
}