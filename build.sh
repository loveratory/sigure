#!/bin/bash
while getopts d:x:v: argument
do
    case $argument in
        D) dir_tgt_full="$OPTARG";;
        x) dir_src="$OPTARG";;
    esac
done

source "${dir_src}/function.sh"