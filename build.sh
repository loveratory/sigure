#!/bin/bash

# 変数リセット/デフォルト値セット
unset check
unset shdir
unset com
unset tweet
unset optmc
unset optrs
unset comm
screen="disable"

# 色表示部
red=31
green=32
yellow=33
blue=34

function outcr {
        color=$1
        shift
        echo -e "\033[${color}m$@\033[m" $3
}

# 環境チェック
## このプログラムの動作にはscreenコマンドが必要です
(type screen) >& /dev/null
if [ $? -eq 1 ]; then
        outcr $red "screenがインストールされていません。" 1>&2
        outcr $red "動作に必要ですのでインストールしてください。" 1>&2
        outcr $red "Ubuntuであれば apt-get install screen で入ります。"
        check="true"
fi

# 異常時の終了処理及びヘルプ表示
usage_exit(){
        echo -e "\n使用法: $0 [-d dir] [-r "device"] [-c] [-s] [-t]" 1>&2
        echo -e " -r: brunchビルドを実行するデバイスネームを指定" 1>&2
        echo -e "-d: コマンドを実行するディレクトリを現在位置からの相対パスか絶対パスで指定" 1>&2
        echo -e "-c: make cleanを行う(オプション)" 1>&2
        echo -e "-s: repo syncを行うか(オプション)" 1>&2
        echo -e "-t: ツイートを行うか(オプション)" 1>&2
        exit 1
}

# 引数処理
while getopts d:r:cstx var
do
    case $var in
        d) shdir=$OPTARG
           (ls $shdir) >& /dev/null
           if [ $? -eq 2 ]; then
              outcr $red "指定されたディレクトリが存在しません。文字列が間違っていないか確認してください。" 1>&2
              check="true"
           fi
           ;;
        r) device=$OPTARG ;;
        c) optmc="-c" ;;
        s) optrs="-s" ;;
        t) tweet="-t" ;;
        x) screen="enable" ;;
    esac
done

if [ "$shdir" = "" ]; then
        outcr $red "ディレクトリが指定されていません。指定してください。" 1>&2
        check="true"
fi
if [ "$device" = "" ]; then
        outcr $red "デバイスが指定されていません。指定してください。" 1>&2
        check="true"
fi

if [ "$check" = "true" ]; then
   usage_exit
fi

# screenで起動しているか確認
## 何故この処理が必要か:
##      リモートシェルでコマンドを実行しているときは突然の問題発生があり得ます。
##      例えば接続断が起きるとコマンドは終了してしまいます。
##      それらのリスクを軽減する為に行います。
if [ "$screen" != "enable" ]; then
        cd $shdir >& /dev/null && source build/envsetup.sh >& /dev/null
        breakfast $device >& /dev/null
        if [ $? -ne 0 ]; then
           outcr $red "デバイスが存在しません。文字列が間違っていないか確認してください。" 1>&2
           usage_exit
        fi
        cd ..
        screen $0 "$@" -x
        exit 0
fi

# ビルド処理
## ビルドフォルダへの移動
cd $shdir

## build/envsetup.shの読み込み
source build/envsetup.sh >& /dev/null

## repo syncを行うか確認
if [ "$optrs" = "-s" ]; then
        outcr $blue "repo syncを開始します。"
        repo sync -j4 --force-sync
fi
## make cleanを行うか確認
if [ "$optmc" = "-c" ]; then
        outcr $blue "make cleanを開始します。"
        make clean
fi

## 設定情報取得前設定
logfiletime=$(date '+%Y-%m-%d_%H-%M-%S')
logfilename="${logfiletime}_${shdir}_${device}"
starttime=$(date '+%Y/%m/%d %T')
logfolder="log"
zipfolder="zip"
source=$shdir
zipdate=$(date -u '+%Y%m%d')
zipname=$(get_build_var CM_VERSION)
if [ "$zipname" = "" ]; then
        zipname="*"
fi

## ソースフォルダ内設定情報を取得
(ls ./config.sh) >& /dev/null
if [ $? -eq 0 ]; then
        . ./config.sh
fi

starttwit="$device 向け $source のビルドを開始します。\n$starttime"

# 設定情報を取得
(ls ../config.sh) >& /dev/null
if [ $? -eq 0 ]; then
        . ../config.sh
fi

# 事前フォルダ作成
mkdir -p ../$logfolder
mkdir -p ../$zipfolder

## ビルド開始ツイート処理
if [ "$tweet" = "-t" ]; then
        echo -e $starttwit | python ../tweet.py
fi

## ビルド実行
outcr $blue "指定されたコマンドを実行します。"
LANG=C
brunch $device 2>&1 | tee "../$logfolder/$logfilename.log"

## ビルド後処理
### ビルドが成功したか確認します。
if [ $(echo ${PIPESTATUS[0]}) -eq 0 ]; then
        res=1
else
        res=0
fi

### ファイル移動
if [ $res -eq 1 ]; then
        mv out/target/product/${device}/${zipname}.zip ../${zipfolder}
fi
cd ..

### 設定情報取得前設定
endstr=$(cat -v "$logfolder/$logfilename.log" | tail -n 3 | tr -d '\n' | cut -d "#" -f 5-5 | cut -c 2-)
endtime=$(date '+%Y/%m/%d %H:%M:%S')
stoptwit="$device 向け $source のビルドが失敗しました。\n$endstr\n$endtime"
endtwit="$device 向け $source のビルドが成功しました!\n$endstr\n$endtime"
endziptwit="$zipname のビルドに成功しました!\n$endstr\n$endtime"

### 設定情報を取得
(ls ./config.sh) >& /dev/null
if [ $? -eq 0 ]; then
        . ./config.sh
fi

### ビルド終了ツイート処理
if [ "$tweet" = "-t" ]; then
        if [ $res -eq 1 ]; then
                if [ "$zipname" != "*" ]; then
                        echo -e $endziptwit | python tweet.py
                else
                        echo -e $endtwit | python tweet.py
                fi
        else
                echo -e $stoptwit | python tweet.py
        fi
fi

echo "終了まで10秒待ちます。Ctrl+Cで終了できます。"
sleep 10
