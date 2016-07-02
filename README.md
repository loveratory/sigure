sigure build tool
==========
## はじめに
Androidのビルドを補助するツールです。  
repo init、repo sync、ビルドフレーバーとしてmake、brunchが可能です。  
また、init時、init異常終了時、sync時、sync終了時、ビルド開始時、ビルド終了時にツイートを行えます。

## ライセンス
パブリックドメイン、CC0とします。  
![CC0](https://licensebuttons.net/l/zero/1.0/88x31.png "クリエイティブ・コモンズ・ライセンス")  
[Creative Commons - CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)

## 導入
Androidビルド推奨環境であるUbuntu系列を想定しています。  
Ubuntu以外でもapt-getを適宜ディストリビューションに合わせれば利用可能かと思われます。  

```
cd ~/
sudo apt install -y bash python python-pip screen
sudo pip install requests_oauthlib
git clone https://github.com/otofune/sigure
ln -s ~/sigure/sigure.sh ~/bin/sigure
```

## ツイートソフトウエアについて
標準で使用されているtweet.pyの利用にはtweet.py内のCK,CS,AT,ASの編集が必要です。  
CK,CS,AT,ASは[Twitter Application Management](https://apps.twitter.com/)にてアプリを作成後取得できます。  
tweet.pyを利用しない場合はpython関連のソフトウエアを入れず、ラッパーであるtweet.shを編集することによってツイートに利用するソフトウエアを変更可能です。

## アップデート

```
cd ~/sigure
git pull
```