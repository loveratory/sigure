#!/bin/bash
function stdlib2_clone () {
    git clone https://github.com/otofune/tweetStdlibPy2.git "${dir_src}/tweetStdlibPy2"
    if [ $? -ne 0 ]; then
        error "* E: clone failed."
        return 1
    fi
}

function stdlib2_config() {
    local json=$1
    local raw
    show -n "* are you sure you want to configuration tweetStdlibPy2 now? [y/n] > "
    while :
    do
        read raw
        case "$raw" in
            "y" ) break ;;
            "n" ) error "* E: configuration canceled."
            return 1
            break ;;
            * ) color red "* please input y or n." ;;
        esac
    done
    show -n "* Twitter API Consumer Key > "
    read raw
    local consumer_key=$raw
    show -n "* Twitter API Consumer Secret > "
    read raw
    local consumer_secret=$raw
    show -n "* Twitter API Access Token > "
    read raw
    local access_token=$raw
    show -n "* Twitter API Access Token Secret > "
    read raw
    local access_token_secret=$raw

    echo -e '{"consumerKey": "'"$consumer_key"'", "consumerSecret": "'"$consumer_secret"'", "accessToken": "'"$access_token"'", "accessTokenSecret": "'"$access_token_secret"'"}' > "$1"
    return 0
}

# tweet wrapper
function wrap_tweet() {
    local string="$1"

    # check whether tweetStdlibPy2 exist
    if [ ! -d "${dir_src}/tweetStdlibPy2" ]; then
        show "* clone tweetStdlib2 for the first time only..."
        stdlib2_clone
    fi
    # check whether the tweetStdlibPy2 config exist
    if [ ! -f "${dir_src}/tweetStdlibPy2/config.json" ]; then
        show "* need configuration tweetStdlibPy2 for the first time only..."
        stdlib2_config "${dir_src}/tweetStdlibPy2/config.json"
    fi

    # tweet
    echo -e "$string" | python2 "$dir_src/tweetStdlibPy2/tweet.py"
}