#!/bin/bash
# input default values
jobs=4
logs=logs
zips=zips

# process arguments
while getopts :D:S:W:d:i:j:ms:t argument
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

# preparing to build
cd "${dir_tgt_full}"
source build/envsetup.sh >& /dev/null
breakfast "$device" >& /dev/null
model=$(get_build_var PRODUCT_MODEL)
variant=$(get_build_var TARGET_BUILD_VARIANT)

# import source configuration
dir_tgt_cut=${dir_tgt_full##*/}
source=$dir_tgt_cut
load_config "${dir_work}" "${dir_tgt_full}"

# kick-start start tweet
tweet "$build_start"

# preparation log folders
mkdir -p "${dir_work}/${logs}/successful"
mkdir -p "${dir_work}/${logs}/logging"
mkdir -p "${dir_work}/${logs}/failed"

# kick-start branch
log="${dir_tgt_cut}_${device}-${variant}_$(date '+%Y%m%d%-H%M%S')"
color blue "* kick-start branch building..."
LANG=C
brunch ${device} 2>&1 | tee "${dir_work}/${logs}/logging/${log}"
result=$?

# move zip/md5sum
if [ $result -eq 0 ]; then
    mkdir -p "${dir_work}/${zips}"
    if [ "$zip" != "" ]; then
        mv --backup=t "${dir_tgt_full}/out/target/product/${device}/${zip}.zip" "${dir_work}/${zips}/"
        mv --backup=t "${dir_tgt_full}/out/target/product/${device}/${zip}.zip.md5sum" "${dir_work}/${zips}/"
    else
        mv --backup=t "${dir_tgt_full}/out/target/product/${device}/"*".zip" "${dir_work}/${zips}/"
        mv --backup=t "${dir_tgt_full}/out/target/product/${device}/"*".zip.md5sum" "${dir_work}/${zips}/"
    fi
fi

# move logs
filter = test $result -eq 0 && echo "successful" || echo "failed"
mv "${dir_work}/${logs}/logging/${log}" "${dir_work}/${logs}/${filter}/${log}"

# end tweets
if [ $result -eq 0 && "$zip" != "" ]; then
    tweet "$build_end_zip"
elif [ $result -eq 0 && "$zip" = "" ]; then
    tweet "$build_end"
else
    tweet "$build_stop"
fi
