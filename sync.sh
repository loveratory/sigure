#!/bin/bash

# カラー関数
red=31
green=32
yellow=33
blue=44

# 引数の事前設定
unset dir
thread=4

function color {
	color=$1
	shift
	echo -e "\033[${color}m$@\033[m" $3
}

# 異常終了関数
usage_exit(){
	echo -e "\n使用法: $0 [-d dir] [-j thread] [-t] [-i URI]" 1>&2
	echo -e "-d: repo syncを行うディレクトリ" 1>&2
	echo -e "-j: repo syncを行うスレッドの数(オプション)" 1>&2
	echo -e "-t: ツイートを行う(オプション)" 1>&2
	echo -e "-i: 指定されたURIでrepo initを行う(オプション)" 1>&2
	exit 1
} 

# screenの存在を確認
(type screen) >& /dev/null
if [ $? -eq 1 ]; then
	color $red "screenがインストールされていません。\nUbuntuでは apt-get install screen でインストールできます。" 1>&2
	finish=true
fi

# 引数処理
while getopts d:j:i:tx var
do
	case $var in
		d) dir=$OPTARG ;;
		j) thread=$OPTARG ;;
		i) init=true
		   URI=$OPTARG ;;
		t) tweet=true ;;
		x) screen=true ;;
	esac
done

if [ "$init" != "true" ]; then
	if [ "$dir" != "" ]; then
		if [ ! -d $dir ]; then
			color $red "指定されたディレクトリが存在しません。入力を間違えていないか確認してください。" 1>&2
			finish=true
		fi
	fi
fi

if [ "$dir" = "" ]; then
	color $red "ディレクトリが指定されていません。" 1>&2
	finish=true
fi

if [ "$finish" = "true" ]; then
	usage_exit
fi

# screen起動/起動確認
if [ ! "$screen" = "true" ]; then
	screen $0 "$@" -x
	exit 0
fi

# 実行フォルダの移動
if [ "$init" = "true" ]; then
	mkdir -p $dir
fi
cd $dir

# repo init 及びソース設定
if [ "$init" = "true" ]; then
        if [ -e ./config.sh ]; then
		source=$dir
                . ./config.sh
        else
		color $blue "ソース名を入力してください"
		echo -n "ソース名: "
		read source
		if [ "$source" = "" ]; then
			source=$dir
		fi
		echo 'source="'$source'"' > ./config.sh
		color $green "ソース名 $source とセットされ設定が保存されました。"
	fi
	startinittime=$(date '+%m/%d %H:%M:%S')
	startinit="$source の repo init を行います。\n$startinittime"

	if [ -e ../config.sh ]; then
		. ../config.sh
	fi

	echo -e $startinit | python ../tweet.py

	repo init -u $URI

	if [ $? -ne 0 ]; then
		stopinittime=$(date '+%m/%d %H:%M:%S')
		stopinit="$source の repo init が異常終了しました。\n$stopinittime"

	        if [ -e ../config.sh ]; then
        	        . ../config.sh
        	fi

        	echo -e $stopinit | python ../tweet.py
	fi
else
	source=$dir
	if [ -e ./config.sh ]; then
		. ./config.sh
	fi
fi

# repo sync 前ツイート
if [ "$tweet" = "true" ]; then
	startsynctime=$(date '+%m/%d %H:%M:%S')
	startsync="$source の repo sync を開始します。\n$startsynctime"
	
	if [ -e ../config.sh ]; then
		. ../config.sh
	fi

	echo -e $startsync | python ../tweet.py
fi

# repo sync 実行/終了文言
repo sync -j$thread
if [ $? -eq 0 ]; then
	res=true
	color $blue "repo syncが成功しました。"
else
	res=false
	color $blue "repo syncが失敗しました。"
fi

# repo sync 後ツイート
if [ "$tweet" = "true" ]; then
	endsynctime=$(date '+%m/%d %H:%M:%S')
	endsync="$source の repo sync が正常終了しました。\n$endsynctime"
	stopsync="$source の repo sync が異常終了しました。\n$endsynctime"
	if [ -e ../config.sh ]; then
		. ../config.sh
	fi
	if [ "$res" = "true" ]; then
		echo -e $endsync | python ../tweet.py
	else
		echo -e $stopsync | python ../tweet.py
	fi
fi
