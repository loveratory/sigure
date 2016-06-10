# twitter.com/siguroidで利用しているスクリプトを置くディレクトリに配置するconfig.sh
startinit="$source の repo init を行います。\n$startinittime #sigurebuild"
stopinit="$source の repo init が異常終了しました。\n$stopinittime #sigurebuild"
startsync="$source の repo sync を開始します。\n$startsynctime #sigurebuild"
stopsync="$source の repo sync が異常終了しました。\n$endsynctime #sigurebuild"
endsync="$source の repo sync が正常終了しました。\n$endsynctime #sigurebuild"
starttwit="$model 向け $source のビルドを開始します。\n$starttime #sigurebuild"
if [ "$endstr" = "" ]; then
	stoptwit="$model 向け $source のビルドが失敗しました。\n$endtime #sigurebuild"
	endtwit="$model 向け $source のビルドが成功しました!\n$endtime #sigurebuild"
	endziptwit="$zipname のビルドに成功しました!\n$endtime #sigurebuild"
else
	stoptwit="$model 向け $source のビルドが失敗しました。\n$endstr\n$endtime #sigurebuild"
	endtwit="$model 向け $source のビルドが成功しました!\n$endstr\n$endtime #sigurebuild"
	endziptwit="$zipname のビルドに成功しました!\n$endstr\n$endtime #sigurebuild"
fi
