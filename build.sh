#!/bin/bash
# input default values
jobs=4

# process arguments
while getopts :D:S:d:i:j:ms:t argument
do
    case $argument in
        D) dir_tgt_full="$OPTARG" ;;
        S) dir_src="$OPTARG" ;;
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

# kick-start tweet
if [ "$tweet" = true ]; then
    :
fi