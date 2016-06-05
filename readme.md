# sigure build tool
## まずはじめに
パブリックドメインとします。ぐちゃぐちゃなのは許して
## 仕様
ビルドしたいソースフォルダの一個上のディレクトリに配置してください。  
```
使用法: ./build.sh [-d dir] [-r device] [-c] [-s] [-t] [-j thread] [-m]
-r: brunchビルドを実行するデバイスネームを指定
-d: コマンドを実行するディレクトリを現在位置からの相対パスか絶対パスで指定
-c: make cleanを行う(オプション)
-s: repo syncを行うか(オプション)
-t: ツイートを行うか(オプション)
-j: repo sync及び-mオプション時のmakeのスレッド数指定(オプション)
-m: brunchではなくmakeで実行する(オプション)
 ```
 
## 導入
```
wget https://raw.githubusercontent.com/otofune/sigure/master/build.sh
wget https://raw.githubusercontent.com/otofune/sigure/master/tweet.py
```
bashがインストールされている必要があります。  
screenというソフトウエアを利用します。  
ツイートはtweet.pyというものに投げており、Pythonのrequests_oauthlibが必要です。  
必要ソフトウエアはUbuntuであれば以下で導入可能です
```
sudo apt-get install bash python-pip screen
pip install requests_oauthlib
```

## その他
[Gist](https://gist.github.com/otofune/7d62b9a5b0737ee67ff4)での旧版が[ほた](https://github.com/lindwurm)氏に[Fork](https://gist.github.com/lindwurm/94a279222197d6f7a68b)され、改良されたものが[lindwurm/madoka](https://github.com/lindwurm/madoka)で公開されています。  
Pushbullet API、MEGA Toolsに対応しており、多機能です。またツイート機能がoysttyer依存です。そちらもどうぞ。

## 設定について
#### tweet.py
tweet.py内のCK,CS,AT,ASに適宜取得したAPIキーを入れておくこと。
#### 実行フォルダ内のconfig.sh
```
starttwit="開始時ツイート内容"
stoptwit="失敗時ツイート内容"
endtwit="zip名が指定されてない場合の成功時ツイート内容"
endziptwit="zip名が指定されている場合の成功時ツイート内容"
```

規定値
- starttime: `$(date '+%Y/%m/%d %T')`  
  `2016/03/29 14:00:08`  
- endtime: `$(date '+%Y/%m/%d %T')`  
  `2016/03/29 13:32:31`
- endstr: `$(tail -2 "$logfolder/$logfilename.log" | head -1 | grep "#" | cut -d "#" -f 5 | cut -c 2- | sed 's/ (hh:mm:ss)/)/g' | sed 's/ (mm:ss)/)/g' | sed 's/ seconds)/s)/g'`  
  `make failed to build some targets (05:22)`
- starttwit: `$device 向け $source のビルドを開始します。\n$starttime`

  ```
  thor 向け Resurrection Remix Marshmallow のビルドを開始します。
  2016/03/29 11:32:41
  ```

- stoptwit: `$device 向け $source のビルドが失敗しました。\n$endstr\n$endtime`

  ```
  thor 向け Resurrection Remix Marshmallow のビルドが失敗しました。
  make failed to build some targets (01:28)  
  2016/03/29 11:41:32
  ```

- endtwit: `$device 向け $source のビルドが成功しました!\n$endstr\n$endtime`

  ```
  thor 向け Ressurection Remix Marshmallow のビルドが成功しました。  
  make completed successfully (54:32)  
  2016/03/29 12:32:53
  ```

- endziptwit: `$zipname のビルドに成功しました!\n$endstr\n$endtime`  

  ```
  ResurrectionRemix-M-v5.6.5-20160329-spyder のビルドに成功しました!  
  make completed successfully (56:19 (mm:ss))  
  2016/03/29 12:43:53
  ```

- zipname: ソースフォルダ内のconfig.shの欄を参照
  
- logfilename: `${logfiletime}\_${shdir}\_${device}`  
  ```
  2016-03-29_14-00-08_RRMM_thor
  ```
- logfolder: `log`
- zipfolder: `zip`

Example:
```
# config.sh
starttwit="$device 向け $source のビルドを開始します。\n$starttime #sigurebuild"
stoptwit="$device 向け $source のビルドが失敗しました。\n$endstr\n$endtime #sigurebuild"
endtwit="$device 向け $source のビルドが成功しました!\n$endstr\n$endtime #sigurebuild"
endziptwit="$zipname のビルドに成功しました!\n$endstr\n$endtime #sigurebuild"
log="log"
zip="zip"
```

#### ソースフォルダ内のconfig.sh
```
source="ツイート時ROM名"
zipname="zip名"
```

規定値
- source: -dオプションで指定されたディレクトリ名  
  `CM13.0`
- zipname: `$(get_build_var CM_VERSION)`  

  ```
  ResurrectionRemix-M-v5.6.5-20160329-spyder
  ```  
    
  BlissPopではBliss_VERSIONで取得できたが、個々のROM毎に違う場合があるので適宜調べてconfig.shに記載すること。取得できない場合endziptwitは行われない。

- zipdate: `$(date -u '+%Y%m%d')`  
  `20160329`
- device: -rオプションの引数が代入される  
 `huashan`

Example:
```
# config.sh
source="CyanogenMod 13.0"
zipname="cm-13.0-${zipdate}-UNOFFICIAL-${device}"
```
