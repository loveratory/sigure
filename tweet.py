#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys

from requests_oauthlib import OAuth1Session

CK = '' # Consumer Key
CS = '' # Consumer Secret
AT = '' # Access Token
AS = '' # Accesss Token Secert

# ツイート投稿用のURL
url = "https://api.twitter.com/1.1/statuses/update.json"

# ツイートする文字列の取得
input = sys.stdin.read()

# ツイートする文字列の確認
print input

# ツイート本文
params = {"status": input}

# OAuth認証で POST method で投稿
twitter = OAuth1Session(CK, CS, AT, AS)
req = twitter.post(url, params = params)

# レスポンスを確認
if req.status_code == 200:
    print ("投稿成功です")
else:
    print ("投稿エラーです: %d" % req.status_code)