# -*- coding: utf-8 -*-
import urllib
import urllib2
import json
import os
import sys
import hashlib
import hmac
import base64
import datetime
import calendar
import random

# Status from Stdin
status = sys.stdin.read()

# Load configuration
try:
    loadConfig = open('key.json', 'r')
    config = json.load(loadConfig)
    loadConfig.close()
except:
    print 'ERR: Invalid key.json'
    sys.exit(1);

# Get UNIX Time
unixTime = calendar.timegm(datetime.datetime.utcnow().timetuple())

# Method / URL
requestMethod = 'POST'
requestUrl = "https://api.twitter.com/1.1/statuses/update.json"

# Generate Nonce
randomInt = random.randint(0, 10000000000000000)
randomHash = hashlib.sha224(str(randomInt)).digest()
nonce = base64.b64encode(randomHash)

# Generate Signature Key
encordedConsumerSecret = urllib.quote_plus(config['consumerSecret'])
encordedAccessTokenSecret = urllib.quote_plus(config['accessTokenSecret'])
signatureKey = encordedConsumerSecret + '&' + encordedAccessTokenSecret

# Generate Signature
materialSignatureStrDic = {
    'status' : status,
    'oauth_signature_method': 'HMAC-SHA1',
    'oauth_consumer_key': config['consumerKey'],
    'oauth_nonce': nonce,
    'oauth_timestamp': str(unixTime),
    'oauth_token': config['accessToken'],
    'oauth_version': '1.0'
}
sortedMaterialSignatureStrDic = sorted(materialSignatureStrDic.items(), key=lambda x: x[0])
materialSignatureStr = urllib.urlencode(sortedMaterialSignatureStrDic)
encordedUrl = urllib.quote_plus(requestUrl)
encordedMaterialSignatureStr = urllib.quote_plus(materialSignatureStr)
signatureStr = requestMethod + '&' + encordedUrl + '&' + encordedMaterialSignatureStr
signature = base64.b64encode(hmac.new(signatureKey, signatureStr, hashlib.sha1).digest())

# Send Request
encordedSignature = urllib.quote_plus(signature)
encordedNonce = urllib.quote_plus(nonce)
encordedConsumerKey = urllib.quote_plus(config['consumerKey'])
encordedAccessToken = urllib.quote_plus(config['accessToken'])
encordedStatus = urllib.quote_plus(status)
authorization = 'OAuth oauth_consumer_key="' + encordedConsumerKey + '",oauth_nonce="' + encordedNonce + '",oauth_signature="' + encordedSignature + '",oauth_signature_method="HMAC-SHA1",oauth_timestamp="' + str(unixTime) + '",oauth_token="' + encordedAccessToken + '",oauth_version="1.0"'
header = {
    'Authorization': authorization
}
param = urllib.urlencode({
    'status': status
})
request = urllib2.Request(requestUrl, param, header)
try:
    result = urllib2.urlopen(request)
except urllib2.HTTPError, e:
    print 'Rejected: ' + str(e.code) + ' ' + e.reason
    rawError = e.read()
    try:
        error = json.loads(rawError)
        errorCode = error['errors'][0]['code']
        errorMessage = error['errors'][0]['message']
        print 'Error Code ' + str(errorCode) + ': ' + errorMessage
    except:
        print rawError
    sys.exit(1)

# Quit
sys.exit()
