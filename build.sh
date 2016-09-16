#!/bin/bash
# process arguments
while getopts :D:S:mt argument
do
    case $argument in
        D) dir_tgt_full="$OPTARG" ;;
        S) dir_src="$OPTARG" ;;
        m) mute=true ;;
        t) tweet=true ;;
    esac
done

# import functions
source "${dir_src}/function.sh"

# kick-start tweet
if [ "$tweet" = true ]; then
    show "* do tweeting"
fi