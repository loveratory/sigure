#!/bin/bash
# input default values
jobs=4

# process arguments
while getopts :D:S:d:i:j:ms:t argument
do
    case $argument in
        D) dir_tgt_full="$OPTARG" ;;
        S) dir_src="$OPTARG" ;;
        W) dir_work="$OPTARG" ;;
        d) device="$OPTARG" ;;
        i) continue ;;
        j) jobs="$OPTARG" ;;
        m) mute=true ;;
        s) continue ;;
        t) tweet=true ;;
        :) continue ;;
        \?) continue ;;
    esac
done

# import functions
source "${dir_src}/function.sh"

# import source configuration
load_config "${dir_work}" "${dir_tgt_full}"

# preparing to build
cd "${dir_tgt_full}"
source build/envsetup.sh

# kick-start start tweet
if [ "$tweet" = true ]; then
    tweet "$start_tweet"
fi
