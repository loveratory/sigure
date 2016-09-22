# import readonly variables
source "${dir_src}/readonly.sh"

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

function center () {
    echo $2 | grep '^[0-9]*$' >& /dev/null
    if [ $? -eq 0 ]; then
        local string=$1
        local length=$2
        local string_length=${#string}
        if [ $string_length -lt $length ]; then
            local blank=`expr \( $2 - $string_length \) / 2`
            local line
            local i=1
            while [ $i -le $blank ]
            do
                line="${line} "
                i=`expr $i + 1`
            done
            show "${line}${string}${line}"
        else
            show "invaild argument" 1>&2
        fi
    else
        show "invaild argument" 1>&2
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

function error() {
    echo -e "\033[31m${1}\033[m" 1>&2
    color green "* I: want help, use -h option." 1>&2
}

function footer () {
    line $len_line
    center "Thanks for using sigure..." $len_line
    exit $1
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
        color green "* Welcome to sigure updator!"
        git_info $1
        local git_commit_older=${git_commit}
        color green "* start updating..."
        cd $1
        git pull >& /dev/null
        if [ $? -ne 0 ]; then
            error "* E: git update failed."
            cd $2
            return 1
        fi
        git_info $1
        if [ "${git_commit_older}" != "${git_commit}" ]; then
            color green "* I: update ${git_commit_older} to ${git_commit}"
        else
            color green "* I: Already up-to-date."
        fi
        cd $2
        return 0
    else
        error "* E: not git directory."
        return 1
    fi
}

function usage () {
    echo -e "* usage: $0 \033[32m[-d device] [-s dir]\033[m [-h] [-m] [-r] [-t] [-u] [-x]" ${1}
    echo -e "* -d: target device \033[32m(required)\033[m" ${1}
    echo -e "* -s: target directory \033[32m(required)\033[m" ${1}
    echo "* -h: show help" ${1}
    echo "* -m: mute mode" ${1}
    echo "* -r: repo sync mode" ${1}
    echo "* -t: tweet mode" ${1}
    echo "* -u: sigure git updator" ${1}
    echo "* -x: direct start-up" ${1}
    echo -e "      do not use screen" ${1}
}