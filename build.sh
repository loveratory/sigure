#!/bin/bash

# 変数除去

unset pararell_jobs
unset log_folder_name
unset zip_folder_name
unset arg_name
unset source_dir
unset target_device
unset fake_branch_mode
unset make_clean
unset repo_sync
unset tweet
unset make_mode
unset screen
unset finish
unset source_name
unset model_name
unset temp
unset get_build_var_cm
unset start_sync_time
unset start_sync_tweet
unset res_sync
unset end_sync_time
unset end_sync_tweet
unset stop_sync_tweet
unset log_file_time
unset log_file_name
unset zip_name
unset start_build_time
unset start_build_tweet
unset res_build
unset end_build_log
unset end_build_time
unset end_build_tweet
unset end_build_zip_tweet
unset stop_build_tweet

# 変数初期値設定

pararell_jobs=4
log_folder_name="logs"
zip_folder_name="zips"

# 基幹設定ファイル読み込み

if [ -f ../config.sh ]; then
    . ../config.sh
fi

# フォルダ作成

mkdir -p $log_folder_name/successful
mkdir -p $log_folder_name/failed
mkdir -p $zip_folder_name

# 定数定義

readonly red=31
readonly green=32
readonly yellow=33
readonly blue=34

# 関数

function color () {
    echo -e "\033[$1m$2\033[m" $3
}

function usage_exit () {
    echo -e "\n使用法: $0 [-d dir] [-r "device"] [-c] [-f] [-j thread] [-m] [-s] [-t] [-x]" 1>&2
    echo -e "-d: ソースディレクトリを現在位置からの相対パスか絶対パス" 1>&2
    echo -e "-r: 実行するデバイスネーム" 1>&2
    echo -e "-c: make cleanを行う(オプション)" 1>&2
    echo -e "-f: brunchではなくfake brunchで行う(オプション)" 1>&2
    echo -e "-j: ジョブ数(オプション)" 1>&2
    echo -e "-m: brunchではなくmakeで行う(オプション)" 1>&2
    echo -e "-s: repo syncを行う(オプション)" 1>&2
    echo -e "-t: ツイートを行う(オプション)" 1>&2
    echo -e "-x: チェック機構を全てスキップ(オプション)" 1>&2
    echo -e "Enterを押すまで終了を待機します..." 1>&2
    read temp
    exit 1
}

function error () {
    echo -e "\n動作環境がセットアップされていないようです。" 1>&2
    echo -e "以下のREADMEを十分に読みセットアップを行ってください。" 1>&2
    echo -e "URL: https://github.com/otofune/sigure/blob/master/readme.md" 1>&2
    echo -e "Enterを押すまで終了を待機します..." 1>&2
    read temp
    exit 1
}

# 引数処理

while getopts d:r:j:fcstmx arg_name
do
    case $arg_name in
        d) source_dir=$OPTARG ;;
        r) target_device=$OPTARG ;;
        f) fake_branch_mode="true" ;;
        c) make_clean="true" ;;
        s) repo_sync="true" ;;
        t) tweet="true" ;;
        j) pararell_jobs=$OPTARG ;;
        m) make_mode="true" ;;
        x) skip="true" ;;
    esac
done

# エラー処理

if [ "$skip" != "true" ]; then

    # screenの存在をチェック

    (type screen) >& /dev/null
    if [ $? -ne 0 ]; then
        color $red "screenがシステムにインストールされていません。" 1>&2
        error
    fi

    # ソースディレクトリ、デバイスツリーディレクトリの存在をチェック

    if [ "$source_dir" = "" ]; then
        color $red "ディレクトリが指定されていません。" 1>&2
        finish="true"
    elif [ ! -d $source_dir ]; then
        color $red "ディレクトリが存在していません。" 1>&2
        finish="true"
    elif [ "$target_device" = "" ]; then
        color $red "デバイスが指定されていません。指定してください。" 1>&2
        check="true"
    fi
    
    # 終了フラグを回収

    if [ "$finish" = "true" ]; then
        usage_exit
    fi
    
    # screenで再起動
    
    screen $0 "$@" -x
    exit 0

fi

# 変数初期値設定

if [ "$tweet" = "true" ]; then
    source_name=$source_dir
    zip_name="*"
fi

# repo sync処理

cd $source_dir

if [ "$repo_sync" = "true" ]; then

    color $blue "repo syncを開始します。"

    # ツイート処理
    if [ "$tweet" = "true" ]; then

        # ソースフォルダ内設定ファイル読み込み

        if [ -f ./config.sh ]; then
            . ./config.sh
        fi

        # 変数初期値設定

        start_sync_time=$(date '+%m/%d %H:%M:%S')
        start_sync_tweet="$source_name の repo sync を開始します。\n$start_sync_time"

        # 基幹設定ファイル読み込み

        if [ -f ../config.sh ]; then
            . ../config.sh
        fi

        echo -e $start_sync_tweet | python ../tweet.py
        
    fi

    repo sync --jobs $pararell_jobs --current-branch --force-broken --force-sync --no-clone-bundle

    res_sync=$?

    # ツイート処理
    if [ "$tweet" = "true" ]; then
    
        source build/envsetup.sh >& /dev/null
        breakfast $target_device >& /dev/null

        # ソースフォルダ内設定ファイル読み込み

        if [ -f ./config.sh ]; then
            . ./config.sh
        fi

        # 変数初期値設定

        end_sync_time=$(date '+%m/%d %H:%M:%S')
        stop_sync_tweet="$source_name の repo sync が異常終了しました。\n$end_sync_time"
        end_sync_tweet="$source_name の repo sync が正常終了しました。\n$end_sync_time"

        # 基幹設定ファイル読み込み

        if [ -f ../config.sh ]; then
            . ../config.sh
        fi

        if [ $res_sync -eq 0 ]; then
            echo -e $end_sync_tweet | python ../tweet.py
        else
            echo -e $stop_sync_tweet | python ../tweet.py
        fi

    fi
    
    # 前処理

    source build/envsetup.sh >& /dev/null
    breakfast $target_device >& /dev/null
    if [ $? -ne 0 ]; then
        color $red "デバイスツリーが正常ではありません。" 1>&2
        usage_exit
    fi

else

    # 前処理

    source build/envsetup.sh >& /dev/null
    breakfast $target_device >& /dev/null
    if [ $? -ne 0 ]; then
        color $red "デバイスツリーが正常ではありません。" 1>&2
        usage_exit
    fi

fi

# ツイート設定処理

if [ "$tweet" = "true" ]; then

    # 変数初期値設定

    model_name=$(get_build_var PRODUCT_MODEL)
    
    # ソースフォルダ内設定ファイル読み込み

    if [ -f ./config.sh ]; then
        . ./config.sh
    fi

fi

# make clean処理

if [ "$make_clean" = "true" ]; then

    color $blue "make cleanを開始します。"
    make clean

fi

# 変数初期値設定

log_file_time=$(date '+%Y-%m-%d_%H-%M-%S')
log_file_name="${log_file_time}_${source_dir}_${target_device}"

# ツイート処理

if [ "$tweet" = "true" ]; then

    # 変数初期値設定

    start_build_time=$(date '+%m/%d %H:%M:%S')
    start_build_tweet="$model_name 向け $source_name のビルドを開始します。\n$start_build_time"
    
    # 基幹設定ファイル読み込み

    if [ -f ../config.sh ]; then
        . ../config.sh
    fi
    
    echo -e $start_build_tweet | python ../tweet.py
    
fi

# ビルド処理

LANG=C
if [ "$fake_branch_mode" = "true" ]; then
    color $blue "ビルドをfake brunchで開始します。"
    mk_timer schedtool -B -n 1 -e ionice -n 1 make -C $(gettop) -j$pararell_jobs bacon 2>&1 | tee "../$log_folder_name/$log_file_name.log"
elif [ "$make_mode" = "true" ]; then
    color $blue "ビルドをmakeで開始します。"
    make -j$pararell_jobs 2>&1 | tee "../$log_folder_name/$log_file_name.log"
else
    color $blue "ビルドをbrunchで開始します。"
    brunch $target_device 2>&1 | tee "../$log_folder_name/$log_file_name.log"
fi

res_build=${PIPESTATUS[0]}

# ファイル移動
if [ $res_build -eq 0 ]; then
    mv --backup=t out/target/product/$target_device/$zip_name/ ../$zip_folder_name
    mv ../$log_folder_name/$log_file_name.log ../$log_folder_name/successful/$log_file_name.log
else
    mv ../$log_folder_name/$log_file_name.log ../$log_folder_name/failed/$log_file_name.log
fi

# 後処理
cd ..

# ツイート処理

if [ "$tweet" = "true" ]; then

    # 変数初期値設定

    end_build_log=$(tail -2 "$log_folder_name/$log_file_name.log" | head -1 | cut -d "#" -f 5 | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' | cut -c 2- | sed 's/ (hh:mm:ss)//g' | sed 's/ (mm:ss)//g' | sed 's/ seconds)/s/g' | sed 's/(//g' | sed 's/)//g' | sed 's/make failed to build some targets/make failed/g' | sed 's/make completed successfully/make successful/g')
    end_build_time=$(date '+%m/%d %H:%M:%S')
    if [ "$end_build_log" = "" ]; then
        stop_build_tweet="$model_name 向け $source_name のビルドが失敗しました。\n$end_build_time"
        end_build_tweet="$model_name 向け $source_name のビルドが成功しました。\n$end_build_time"
        end_build_zip_tweet="$zip_name のビルドが成功しました。\n$end_build_time"
    else
        stop_build_tweet="$model_name 向け $source_name のビルドが失敗しました。\n$end_build_log\n$end_build_time"
        end_build_tweet="$model_name 向け $source_name のビルドが成功しました。\n$end_build_log\n$end_build_time"
        end_build_zip_tweet="$zip_name のビルドが成功しました。\n$end_build_log\n$end_build_time"
    fi

    # 基幹設定ファイル読み込み
    
    if [ -f ./config.sh ]; then
        . ./config.sh
    fi
    
    if [ $res_build -eq 0 ]; then
        if [ "$zip_name" != "*" ]; then
            echo -e $end_build_zip_tweet | python tweet.py
        else
            echo -e $end_build_tweet | python tweet.py
        fi
    else
        echo -e $stop_build_tweet | python tweet.py
    fi
    
fi

# ビルド時の終了ステータスと同じ値を返す
exit $res_build
