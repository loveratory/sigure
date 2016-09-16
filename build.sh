#!/bin/bash
# process arguments
while getopts :D:S:d:mt argument
do
    case $argument in
        D) dir_tgt_full="$OPTARG" ;;
        S) dir_src="$OPTARG" ;;
        d) continue ;;
        m) mute=true ;;
        t) tweet=true ;;
        :) continue ;;
        \?) continue ;;
    esac
done

# import functions
source "${dir_src}/function.sh"

# kick-start tweet
if [ "$tweet" = true ]; then
    show "* do tweeting"
fi