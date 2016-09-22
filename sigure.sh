#!/bin/bash
unset scr_main
unset dir_src
unset dir_run

# assign paths
scr_main=$(readlink -f $0)
dir_src=${scr_main%/*}
dir_work=$(pwd)

# input default values
jobs=4

# import functions
source "${dir_src}/function.sh"

# reset variables
source "${dir_src}/reset.sh"

# process arguments
while getopts :d:hi:j:mrs:ux argument
do
    case $argument in
        d) device="$OPTARG" ;;
        h) help=true ;;
        i) repo_init="$OPTARG"
           repo_sync=true ;;
        j) jobs="$OPTARG" ;;
        m) mute=true ;;
        r) repo_sync=true ;;
        s) dir_tgt="$OPTARG" ;;
        u) update=true ;;
        x) direct=true ;;
        :) continue ;;
        \?) continue ;;
    esac
done

# assign git information
git_info "${dir_src}"

# welcome message
center "Welcome to sigure! <${git_branch}>" $len_line
center "commit: ${git_commit}" $len_line
line $len_line

# kick-start help
if [ "$help" = true ]; then
    usage
    footer 0
fi

# kick-start updator
if [ "$update" = true ]; then
    git_update "$dir_src" "$dir_work"
    footer $?
fi

# check whether the target directory exist
show "* check whether the target directory exist..."
if [ "$dir_tgt" = "" ]; then
    error "* E: target directory is unspecified."
    footer 1
fi
if [ "$repo_init" = "" ]; then
    if [ -d "${dir_run}/${dir_tgt}" ]; then
        dir_tgt_full="${dir_run}/${dir_tgt}"
    elif [ -d "$dir_tgt" ]; then
        dir_tgt_full=$(readlink -f "$dir_tgt")
    else
        error "* E: target directory does not exist."
        footer 1
    fi
else
    echo $dir_tgt | grep "/" >& /dev/null
    if [ $? -eq 0 ]; then
        error "* E: source directory with repo init mode, need directory directly under."
        footer 1
    fi
    dir_tgt_full="${dir_work}/${dir_tgt}"
fi

# check $jobs is number.
show '* check var $jobs is number...'
if [ "$jobs" = "" ]; then
    error "* E: invaild -j option argument."
    footer 1
fi
check_numeric "$jobs"
if [ $? -eq 1 ]; then
    error "* E: invaild -j option argument."
    footer 1
fi

# kick-start repo init
if [ "$repo_init" != "" ]; then
    show "* kick-start repo init..."
    repo_init "$dir_work" "$repo_init" "$dir_tgt_full"
    if [ $? -ne 0 ]; then
        footer 1
    fi
fi

# kick-start repo sync
if [ "$repo_sync" = true ]; then
    show "* kick-start repo sync..."
    repo_sync "$dir_work" "$jobs" "$dir_tgt_full"
    if [ $? -ne 0 ]; then
        footer 1
    fi
fi

# check whether the source code prepared
show "* check whether the source code prepared..."
cd "$dir_tgt_full"
source build/envsetup.sh >& /dev/null
if [ $? -ne 0 ]; then
    error "* E: source code is unprepared."
    footer 1
fi

# check whether the target device exist
show "* check whether the target device exist..."
if [ "$device" = "" ]; then
    error "* E: target device is unspecified."
    footer 1
else
    breakfast "$device" >& /dev/null
    if [ $? -ne 0 ]; then
        error "* E: device tree is unprepared."
        footer 1
    fi
    cd "$dir_work"
fi

# ALL CLEAR!
color green "* congratulations! all testing passed!"

# kick-start build
if [ "$direct" = true ]; then
    show "* direct kick-start building..."
    bash "${dir_src}/build.sh" -D "${dir_tgt_full}" -S "${dir_src}" "$@"
    footer $?
else
    type screen >& /dev/null
    if [ $? -ne 0 ]; then
        error "* E: screen not installed."
        show "* you don't need start with screen, use -x option." 1>&2
        footer 1
    fi
    show "* kick-start building with screen..."
    screen bash "${dir_src}/build.sh" -D "${dir_tgt_full}" -S "${dir_src}" "$@"
    footer 0
fi