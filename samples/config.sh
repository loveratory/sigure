# twitter.com/siguroidで利用しているスクリプトを置くディレクトリに配置するconfig.sh
start_init_tweet="$source_name の repo init を行います。\n$start_init_time #sigurebuild"
stop_init_tweet="$source_name の repo init が異常終了しました。\n$stop_init_time #sigurebuild"
start_sync_tweet="$source_name の repo sync を開始します。\n$start_sync_time #sigurebuild"
stop_sync_tweet="$source_name の repo sync が異常終了しました。\n$end_sync_time #sigurebuild"
end_sync_tweet="$source_name の repo sync が正常終了しました。\n$end_sync_time #sigurebuild"
start_build_tweet="$model_name 向け $source_name のビルドを開始します。\n$start_build_time #sigurebuild"
if [ "$end_build_log" = "" ]; then
	stop_build_tweet="$model_name 向け $source_name のビルドが失敗しました。\n$end_build_time #sigurebuild"
	end_build_tweet="$model_name 向け $source_name のビルドが成功しました!\n$end_build_time #sigurebuild"
	end_build_zip_tweet="$zip_name のビルドに成功しました!\n$end_build_time #sigurebuild"
else
	stop_build_tweet="$model_name 向け $source_name のビルドが失敗しました。\n$end_build_log\n$end_build_time #sigurebuild"
	end_build_tweet="$model_name 向け $source_name のビルドが成功しました!\n$end_build_log\n$end_build_time #sigurebuild"
	end_build_zip_tweet="$zip_name のビルドに成功しました!\n$end_build_log\n$end_build_time #sigurebuild"
fi
