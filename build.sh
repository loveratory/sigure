#!/bin/bash
while getopts :D:S:m argument
do
    case $argument in
        D) dir_tgt_full="$OPTARG";;
        S) dir_src="$OPTARG" ;;
        m) mute=true ;;
    esac
done

source "${dir_src}/function.sh"