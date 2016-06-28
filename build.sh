#!/bin/bash

# デフォルト値セット
unset make
screen="disable"
thread=4

# 色表示部
red=31
green=32
yellow=33
blue=34

function color {
        color=$1
        shift
        echo -e "\033[${color}m$@\033[m" $3
}

# 環境チェック
## このプログラムの動作にはscreenコマンドが必要です
(type screen) >& /dev/null
if [ $? -eq 1 ]; then
        color $red "screenがインストールされていません。" 1>&2
        color $red "動作に必要ですのでインストールしてください。" 1>&2
        color $red "Ubuntuであれば apt-get install screen で入ります。"
        check="true"
fi

# 異常時の終了処理及びヘルプ表示
usage_exit(){
        echo -e "\n使用法: $0 [-d dir] [-r "device"] [-c] [-f] [-j thread] [-m] [-s] [-t] [-x]" 1>&2
        echo -e "-d: ソースディレクトリを現在位置からの相対パスか絶対パス" 1>&2
	echo -e "-r: 実行するデバイスネーム" 1>&2
	echo -e "-c: make cleanを行う(オプション)" 1>&2
	echo -e "-f: brunchではなくfake brunchで行う(オプション)" 1>&2
	echo -e "-j: repo sync、-fオプション時のfake brunch、-mオプション時のmakeのジョブ数(オプション)" 1>&2
	echo -e "-m: brunchではなくmakeで行う(オプション)" 1>&2
        echo -e "-s: repo syncを行う(オプション)" 1>&2
        echo -e "-t: ツイートを行う(オプション)" 1>&2
	echo -e "-x: screenチェックをスキップ(オプション)" 1>&2
        exit 1
}

# 引数処理
while getopts d:r:j:fcstmx var
do
    case $var in
        d) shdir=$OPTARG ;;
        r) device=$OPTARG ;;
	f) fakebrunch="enable" ;;
        c) optmc="-c" ;;
        s) optrs="-s" ;;
        t) tweet="-t" ;;
	j) thread=$OPTARG ;;
	m) make="enable" ;;
        x) screen="enable" ;;
    esac
done

if [ "$shdir" = "" ]; then
        color $red "ディレクトリが指定されていません。指定してください。" 1>&2
        check="true"
elif [ ! -e $dir ]; then
	color $red "指定されたディレクトリが存在しません。指定が間違っていないか確認してください。" 1>&2
	check="true"
else 
        cd $shdir >& /dev/null && source build/envsetup.sh >& /dev/null
        breakfast $device >& /dev/null
        if [ $? -ne 0 ]; then
                color $red "デバイスツリーが存在しないか不正です。入力が間違っていないか確認してください。" 1>&2
                check="true"
        fi
        cd ..
fi

if [ "$device" = "" ]; then
        color $red "デバイスが指定されていません。指定してください。" 1>&2
        check="true"
fi

if [ "$check" = "true" ]; then
	usage_exit
fi

# screenで起動しているか確認
if [ "$screen" != "enable" ]; then
        screen $0 "$@" -x
        exit 0
fi

# ビルド処理
## ビルドディレクトリへの移動
cd $shdir

## 事前設定
source=$shdir
logfolder="log"
zipfolder="zip"

## 設定情報を取得
if [ -e ./config.sh ]; then
        . ./config.sh
fi
if [ -e ../config.sh ]; then
        . ../config.sh
fi

# 事前ディレクトリ作成
mkdir -p ../$logfolder
mkdir -p ../$zipfolder

## build/envsetup.shの読み込み
source build/envsetup.sh >& /dev/null
breakfast $device >& /dev/null


## repo syncを行うか確認
if [ "$optrs" = "-s" ]; then
	## デフォルト値セット
	startsynctime=$(date '+%m/%d %H:%M:%S')
	startsync="$source の repo sync を開始します。\n$startsynctime"
	
	# 設定情報を取得
	(ls ../config.sh) >& /dev/null
	if [ $? -eq 0 ]; then
	        . ../config.sh
	fi
	
        color $blue "repo syncを開始します。"
	if [ "$tweet" = "-t" ]; then
		echo -e $startsync | python ../tweet.py
	fi

        repo sync --jobs $thread --current-branch --force-broken --force-sync --no-clone-bundle

        res=$?

	if [ "$tweet" = "-t" ]; then
		endsynctime=$(date '+%m/%d %H:%M:%S')
		endsync="$source の repo sync が正常終了しました。\n$endsynctime"
		stopsync="$source の repo sync が異常終了しました。\n$endsynctime"
		if [ -e ../config.sh ]; then
			. ../config.sh
		fi
		if [ $res -eq 0 ]; then
			echo -e $endsync | python ../tweet.py
		else
			echo -e $stopsync | python ../tweet.py
		fi
	fi
fi

## make cleanを行うか確認
if [ "$optmc" = "-c" ]; then
        color $blue "make cleanを開始します。"
        make clean
fi

## 設定情報取得前設定
logfiletime=$(date '+%Y-%m-%d_%H-%M-%S')
logfilename="${logfiletime}_${shdir}_${device}"
model=$(get_build_var PRODUCT_MODEL)
starttime=$(date '+%m/%d %H:%M:%S')
zipdate=$(date -u '+%Y%m%d')
getvar=$(get_build_var CM_VERSION)
zipname=$getvar
if [ "$zipname" = "" ]; then
        zipname="*"
fi

## ソースディレクトリ内設定情報を取得
if [ -e ./config.sh ]; then
        . ./config.sh
fi

starttwit="$model 向け $source のビルドを開始します。\n$starttime"

## 設定情報を取得
if [ -e ../config.sh ]; then
        . ../config.sh
fi

## ビルド開始ツイート処理
if [ "$tweet" = "-t" ]; then
        echo -e $starttwit | python ../tweet.py
fi

## ビルド実行
LANG=C
if [ "$make" = "enable" ]; then
	color $blue "ビルドをmakeで開始します。"
	make -j$thread 2>&1 | tee "../$logfolder/$logfilename.log"
elif [ "$fakebrunch" = "enable" ]; then
	color $blue "ビルドをfake brunchで開始します。"
	schedtool -B -n 1 -e ionice -n 1 make -C $(gettop) -j$thread bacon 2>&1 | tee "../$logfolder/$logfilename.log"
else
	color $blue "ビルドをbrunchで開始します。"
	brunch $device 2>&1 | tee "../$logfolder/$logfilename.log"
fi

result=${PIPESTATUS[0]}

### ファイル移動
if [ $result -eq 0 ]; then
        mv --backup=t out/target/product/${device}/${zipname}.zip ../${zipfolder}
fi
cd ..

### 設定情報取得前設定
unset endstr
endstr=$(tail -2 "$logfolder/$logfilename.log" | head -1 | cut -d "#" -f 5 | cut -c 2- | sed 's/ (hh:mm:ss)//g' | sed 's/ (mm:ss)//g' | sed 's/ seconds)/s/g' | sed 's/(//g' | sed 's/)//g' | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' | sed 's/make failed to build some targets/make failed/g' | sed 's/make completed successfully/make successful/g')
endtime=$(date '+%m/%d %H:%M:%S')
if [ "$endstr" = "" ]; then
        stoptwit="$model 向け $source のビルドが失敗しました。\n$endtime"
        endtwit="$model 向け $source のビルドが成功しました!\n$endtime"
        endziptwit="$zipname のビルドに成功しました!\n$endtime"
else
	stoptwit="$model 向け $source のビルドが失敗しました。\n$endstr\n$endtime"
	endtwit="$model 向け $source のビルドが成功しました!\n$endstr\n$endtime"
	endziptwit="$zipname のビルドに成功しました!\n$endstr\n$endtime"
fi

### 設定情報を取得
if [ -e ./config.sh ]; then
        . ./config.sh
fi

### ビルド終了ツイート処理
if [ "$tweet" = "-t" ]; then
        if [ $result -eq 0 ]; then
                if [ "$zipname" != "*" ]; then
                        echo -e $endziptwit | python tweet.py
                else
                        echo -e $endtwit | python tweet.py
                fi
        else
                echo -e $stoptwit | python tweet.py
        fi
fi

### ビルドのコマンドと同じ終了ステータスを渡す
exit $result
