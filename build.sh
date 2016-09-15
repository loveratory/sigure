#!/bin/bash
while getopts d:x:v: argument
do
    case $argument in
        d) dir_run="$OPTARG";;
        x) dir_src="$OPTARG";;
        v) verbose="$OPTARG" ;;
    esac
done

source "${dir_src}/function.sh"