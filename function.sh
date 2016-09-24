# import readonly variables
source "${dir_src}/readonly.sh"
source "${dir_src}/wrap_tweet.sh"

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

function repo_init() {
    local work=$1
    local URL=$2
    local target=$3
    local raw
    mkdir -p $target
    cd $target
    show -n "* please input init source name... > "
    read raw
    if [ "$raw" != "" ]; then
        source=$raw
        echo 'source="'"$source"'"' > "$target/config.sh"
        if [ $? -ne 0 ]; then
            error "* E: save failed."
        else
            show "* configuration saved."
        fi
    fi
    repo init -u $URL
    local result=$?
    cd $work
    if [ $result -eq 127 ]; then
        error "* E: repo not installed."
    elif [ $result -ne 0 ]; then
        error "* E: repo init failed."
    fi
    return $result
}

function repo_sync() {
    local work=$1
    local pararell=$2
    local target=$3
    cd $target
    repo sync --jobs $pararell --current-branch --force-broken --force-sync --no-clone-bundle
    local result=$?
    cd $work
    if [ $result -eq 127 ]; then
        error "* E: repo not installed."
    elif [ $result -ne 0 ]; then
        error "* E: repo sync failed."
    fi
    return $result
}

function make_clean() {
    local work=$1
    local pararell=$2
    local target=$3
    cd $target
    make clean -j ${pararell}
    local result=$?
    cd $work
    if [ $result -ne 0 ]; then
        error "* E: make clean failed."
    fi
    return $result
}

function check_numeric() {
    local check=$1
    local except_numeric=`echo $check | sed 's/[0-9]//g'`
    if [ "$except_numeric" = "" ]; then
        return 0
    fi
    return 1
}

function tweet() {
    if [ "$tweet" = true ]; then
        local base_string=$1
        local time=`date '+%m\/%d %H:%M:%S'`
        local string=$(echo $base_string | sed -e "s/%time/$time/g" -e "s/%source/$source/g" -e "s/%model/$model/g" -e "s/%zip/$zip/g")
        wrap_tweet "${string}"
        if [ $? -ne 0 ]; then
            error "E: tweet failed."
            return 1
        fi
        return 0
    fi
}

function load_config() {
    local work=$1
    local target=$2
    local sigure=$3
    if [ -f "${sigure}/config.sh" ]; then
        source "${sigure}/config.sh"
    fi
    if [ -f "${work}/config.sh" ]; then
        source "${work}/config.sh"
    fi
    if [ -f "${target}/config.sh" ]; then
        source "${target}/config.sh"
    fi
}

function usage () {
    echo -e "* usage: $0 \033[32m[-d device] [-s dir]\033[m [-c] [-h] [-i URL] [-j number] [-m] [-r] [-t] [-u] [-x]" ${1}
    echo -e "* -d: target device \033[32m(required)\033[m" ${1}
    echo -e "* -s: target directory \033[32m(required)\033[m" ${1}
    echo "* -c: make clean" ${1}
    echo "* -h: show help" ${1}
    echo "* -i: repo init" ${1}
    echo "      ex. $0"' -i "git://github.com/CyanogenMod/android.git -b cm-13.0"'
    echo "* -j: job threads" ${1}
    echo "* -m: mute mode" ${1}
    echo "* -r: repo sync" ${1}
    echo "* -t: tweet mode" ${1}
    echo "* -u: sigure git updator" ${1}
    echo "* -x: direct start-up" ${1}
    echo "      do not use screen" ${1}
}
