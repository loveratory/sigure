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
	echo -e "\n使用法: $0 [-d dir] [-j thread] [-t]" 1>&2
	echo -e "-d: repo sync を行うディレクトリ" 1>&2
	echo -e "-j: repo sync を行うスレッドの数(オプション)" 1>&2
	echo -e "-t: ツイートを行う(オプション)" 1>&2
	exit 1
} 

# screenの存在を確認
(type screen) >& /dev/null
if [ $? -eq 1 ]; then
	color $red "screenがインストールされていません。\nUbuntuでは apt-get install screen でインストールできます。" 1>&2
	finish=true
fi

# 引数処理
while getopts d:j:tx var
do
	case $var in
		d) dir=$OPTARG
		   (ls $dir) >& /dev/null
		   if [ $? -eq 2 ]; then
			color $red "指定されたディレクトリが存在しません。入力を間違えていないか確認してください。" 1>&2
			finish=true
		   fi ;;
		j) thread=$OPTARG ;;
		t) tweet=true ;;
		x) screen=true ;;
	esac
done

if [ "$dir" == "" ]; then
	color $red "ディレクトリが指定されていません。" 1>&2
	finish=true
fi

if [ $finish ]; then
	usage_exit
fi

# screen起動/起動確認
if [ ! $screen ]; then
	screen $0 "$@" -x
	exit 0
fi

# 実行ディレクトリへ移動
cd $dir

# ソース設定
source=$dir
(ls ./config.sh) >& /dev/null
if [ $? -eq 0 ]; then
	. ./config.sh
fi

# repo sync 開始
stopsync="$source の repo sync が異常終了しました。\n$endtime"

# repo sync 前ツイート
if [ $tweet ]; then
	startsynctime=$(date '+%m/%d %H:%M:%S')
	startsync="$source の repo sync を開始します。\n$startsynctime"
	
	(ls ../config.sh) >& /dev/null
	if [ $? -eq 0 ]; then
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
if [ $tweet ]; then
	endsynctime=$(date '+%m/%d %H:%M:%S')
	endsync="$source の repo sync が正常終了しました。\n$endsynctime"
	stopsync="$source の repo sync が異常終了しました。\n$endsynctime"
	(ls ../config.sh) >& /dev/null
	if [ $? -eq 0 ]; then
		. ../config.sh
	fi
	if [ $res ]; then
		echo -e $endsync | python ../tweet.py
	else
		echo -e $stopsync | python ../tweet.py
	fi
fi
