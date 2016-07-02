sigure build tool
==========
## はじめに
Androidのビルドを補助するツールです。  
repo init、repo sync、ビルドフレーバーとしてmake、brunchが可能です。  
また、init時、init異常終了時、sync時、sync終了時、ビルド開始時、ビルド終了時にツイートを行えます。

## 導入
```
cd ~/
sudo apt install -y bash python python-pip screen
sudo pip install requests_oauthlib
git clone https://github.com/otofune/sigure
ln -s ~/sigure/sigure.sh ~/bin/sigure
```  
更新時は `cd ~/sigure && git pull` するだけで更新が可能です。  
tweet.pyの利用にはtweet.py内のCK,CS,AT,ASが必要です。  
tweet.pyを利用しない場合はpython関連のソフトウエアを入れず、ラッパーであるtweet.shを編集することによってツイートに利用するソフトウエアを変更可能です。
