sigure build tool
==========
## はじめに
Androidのビルドを補助するツールです。  
repo init、repo sync、ビルドフレーバーとしてmake、brunchが可能です。  
また、init時、init異常終了時、sync時、sync終了時、ビルド開始時、ビルド終了時にツイートを行えます。

## ライセンス
パブリックドメインとして権利を放棄しています。[LICENSE](LICENSE)をご覧ください。

## 導入
Androidビルド推奨環境であるUbuntu系列を想定しています。  
Ubuntu以外でもaptを適宜ディストリビューションに合わせれば利用可能かと思われます。  

```
cd ~/
sudo apt install -y bash python screen
git clone https://github.com/otofune/sigure
mkdir -p ~/bin
ln -s ~/sigure/sigure.sh ~/bin/sigure
```

## アップデート

```
cd ~/sigure
git pull
```

## PATHへの追加
.bashrcに下記を追記:  
```
if [ -d $HOME/bin ]; then
        export PATH=$HOME/bin:$PATH
fi
```

## ツイートソフトウエアについて
[tweetStdlibPy2](https://github.com/otofune/tweetStdlibPy2)を使用しています。  
これは、Python 2で動作するものです。  
sigureを保存しているディレクトリ上のkey.jsonからAPIキーを読み取ります。  
サンプル:  
```
{
        "consumerKey": "xvz1evFS4wEEPTGEFPHBog",
        "consumerSecret": "kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw",
        "accessToken": "370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb",
        "accessTokenSecret": "LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE"
}
```
tweet.pyを利用しない場合はpython関連のソフトウエアを入れず、ラッパーであるtweet.shを編集することによってツイートに利用するソフトウエアを変更可能です。