# sigure build tool
## まずはじめに
ライセンスはパブリック・ドメインとします。  
Twitter: [@siguroid](https://twitter.com/siguroid) を動かしているコードです。

## 仕様
ビルドしたいソースディレクトリの一個上のディレクトリに配置してください。  

```
使用法: ./build.sh [-d dir] [-r device] [-c] [-f] [-j thread] [-m] [-s] [-t] [-x]
-d: ソースディレクトリを現在位置からの相対パスか絶対パス
-r: 実行するデバイスネーム
-c: make cleanを行う(オプション)
-f: brunchではなくfake brunchで行う(オプション)
-j: repo sync、-fオプション時のfake brunch、-mオプション時のmakeのジョブ数(オプション)
-m: brunchではなくmakeで行う(オプション)
-s: repo syncを行う(オプション)
-t: ツイートを行う(オプション)
-x: screenチェックをスキップ(オプション)
```

```
使用法: ./sync.sh [-d dir] [-j thread] [-t] [-i URI]
-d: repo syncを行うディレクトリ
-j: repo syncを行うジョブ数(オプション)
-t: ツイートを行う(オプション)
-i: 指定されたURIでrepo initを行う(オプション)
```
 
## 導入
```
cd ~/
wget https://raw.githubusercontent.com/otofune/sigure/master/build.sh
wget https://raw.githubusercontent.com/otofune/sigure/master/sync.sh
wget https://raw.githubusercontent.com/otofune/sigure/master/tweet.py
chmod 755 build.sh sync.sh
```
bashがインストールされている必要があります。  
screenというソフトウエアを利用します。  
ツイートはtweet.pyというものに投げており、Pythonのrequests_oauthlibが必要です。  
必要ソフトウエアはUbuntuであれば以下で導入可能です
```
sudo apt-get install bash python-pip screen
pip install requests_oauthlib
```

## 注意点
repo.shにおいて、URIとされているフィールドに入れた文字列はrepo init $URIとして実行されるため、ブランチの指定も入れて良いが、空白が含まれる場合はダブルクオーテーションで囲って指定すること。

```
./sync.sh -d AICP -i "https://github.com/AICP/platform_manifest.git -b mm6.0" -j 4 -t
```

## その他
[Gist](https://gist.github.com/otofune/7d62b9a5b0737ee67ff4)での旧版が[ほた](https://github.com/lindwurm)氏に[Fork](https://gist.github.com/lindwurm/94a279222197d6f7a68b)され、改良されたものが[lindwurm/madoka](https://github.com/lindwurm/madoka)で公開されています。  
Pushbullet API、MEGA Toolsに対応しており、多機能です。またツイート機能がoysttyer依存です。そちらもどうぞ。

## 設定について
### tweet.py
tweet.py内のCK,CS,AT,ASに適宜取得したAPIキーを入れておくこと。

### config.sh
[sample](https://github.com/otofune/sigure/tree/master/sample)  
を参考に以下の規定値を活かして適宜改変すること。

#### 実行ディレクトリ内のconfig.sh

規定値
- starttime: `$(date '+%Y/%m/%d %T')`  

  ```
  2016/03/29 14:00:08
  ```

- endtime: `$(date '+%Y/%m/%d %T')`  

  ```
  2016/03/29 13:32:31
  ```

- endstr: `$(tail -2 "$logfolder/$logfilename.log" | head -1 | grep "#" | cut -d "#" -f 5 | cut -c 2- | sed 's/ (hh:mm:ss)/)/g' | sed 's/ (mm:ss)/)/g' | sed 's/ seconds)/s)/g'`  

  ```
  make failed to build some targets (05:22)
  ```

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

- zipname: ソースディレクトリ内のconfig.shの欄を参照
  
- logfilename: `${logfiletime}\_${shdir}\_${device}`  

  ```
  2016-03-29_14-00-08_RRMM_thor
  ```

- logfolder: `log`
- zipfolder: `zip`


#### ソースディレクトリ内のconfig.sh

規定値
- source: -dオプションで指定されたディレクトリ名  

  ```
  CM13.0
  ```

- getvar: `$(get_build_var CM_VERSION)`

  ```
  ResurrectionRemix-M-v5.6.5-20160329-spyder
  ```  

- zipname: `$getvar`  

- zipdate: `$(date -u '+%Y%m%d')`  

  ```
  20160329
  ```

- device: -rオプションの引数が代入される  

  ```
  huashan
  ```
