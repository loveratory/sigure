# -*- coding: utf-8 -*-
import urllib, urllib2, json, os, sys, hashlib, hmac, base64, datetime, calendar, random
from HTMLParser import HTMLParser

'''
class PostError (Exception):
    Exception class from post_tweet().

    return:
        code:   Error Code from urllib2.HTTPError.code
        reason: Error Reason from urllib2.HTTPError.reason
        read:   Responce when Happened Error from urllib2.HTTPError.read()
'''
class PostError(Exception):
    def __init__(self, code, reason, read):
        self.code = code
        self.reason = reason
        self.read = read

'''
class parse_onetag:
    Parse one HTML tag.

    arg:
        data:   One HTML Tag
    return:
        data:   Content of a Tag
'''
class parse_onetag(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
    def handle_data(self, data):
        self.data = data

'''
def load_json:
    Load json file to dictionary.

    arg:
        path:   file path
'''
def load_json(path):
    try:
        f = open(path, 'r')
        j = json.load(f)
        f.close()
    except IOError as e:
        raise e
    except ValueError as e:
        raise e
    return j

'''
def gen_signature:
    Generate OAuth1.0a signature.

    arg:
        consumer_secret:    OAuth Consumer Secret
        token_secret:       OAuth Token Secret
        method:             HTTP Method
        query:              HTTP Query
        url:                HTTP Request URL
'''
def gen_signature(consumer_secret, token_secret, method, query, url):
    # generate signature key
    signature_key = str(urllib.quote_plus(consumer_secret) + '&' + urllib.quote_plus(token_secret))
    # combine query
    sorted_query = sorted(query.items(), key=lambda x: x[0])
    combine_query = urllib.urlencode(sorted_query).replace('+', '%20')
    # compile signature
    signature_base_string = str(urllib.quote_plus(method) + '&' + urllib.quote_plus(url) + '&' + urllib.quote_plus(combine_query))
    signature = base64.b64encode(hmac.new(signature_key, signature_base_string, hashlib.sha1).digest())
    return signature

'''
def gen_nonce:
    Generate random OAuth nonce.
'''
def gen_nonce():
    random_hash = hashlib.sha224(str(random.randint(0, 10000000000000000))).digest()
    nonce = base64.b64encode(random_hash)
    return nonce

'''
def gen_authorization:
    Generate OAuth1.0a Authorize header.

    arg:
        consumer_key:   OAuth Consumer Key
        token:          OAuth Token
        nonce:          OAuth Nonce
        signature:      OAuth Signature
        unixtime:       Unix Time
'''
def gen_authorization(consumer_key, token, nonce, signature, unixtime):
    authorization = 'OAuth oauth_consumer_key="' + urllib.quote_plus(consumer_key) \
        + '",oauth_nonce="' + urllib.quote_plus(nonce) \
        + '",oauth_signature="' + urllib.quote_plus(signature) \
        + '",oauth_signature_method="HMAC-SHA1",oauth_timestamp="' + str(unixtime) \
        + '",oauth_token="' + urllib.quote_plus(token) \
        + '",oauth_version="1.0"'
    return authorization

'''
def get_unixtime:
    Get system UNIX time.
'''
def get_unixtime():
    return calendar.timegm(datetime.datetime.utcnow().timetuple())

'''
def post_tweet:
    Post Tweet with any Twitter Application.

    arg:
        status:             Tweet String
        consumer_key:       OAuth Consumer Key
        consumer_secret:    OAuth Consumer Secret
        token:              OAuth Token
        token_secret:       OAuth Token Secret
'''
def post_tweet(status, consumer_key, consumer_secret, token, token_secret):
    method = 'POST'
    url = 'https://api.twitter.com/1.1/statuses/update.json'

    unixtime = get_unixtime()
    nonce = gen_nonce()
    query = {
        'status' : status,
        'oauth_signature_method': 'HMAC-SHA1',
        'oauth_consumer_key': consumer_key,
        'oauth_nonce': nonce,
        'oauth_timestamp': str(unixtime),
        'oauth_token': token,
        'oauth_version': '1.0'
    }

    signature = gen_signature(consumer_secret, token_secret, method, query, url)
    authorization = gen_authorization(consumer_key, token, nonce, signature, unixtime)

    param = 'status=' + urllib.quote_plus(status).replace('+', '%20')
    header = {'Authorization': authorization}

    request = urllib2.Request(url, param, header)

    try:
        result = urllib2.urlopen(request)
    except urllib2.HTTPError as e:
        raise PostError(e.code, e.reason, e.read())

    read = result.read()
    result.close()
    return read

'''
if __name__ == '__main__':
    Run when direct start-up
'''
if __name__ == '__main__':
    path = os.path.dirname(os.path.abspath(__file__))
    status = sys.stdin.read()
    try:
        config = load_json(path + os.sep + 'key.json')
    except IOError as e:
        print(e)
        sys.exit(1)
    except ValueError as e:
        print(e)
        sys.exit(1)

    try:
        post = post_tweet(status, config['consumerKey'], config['consumerSecret'], config['accessToken'], config['accessTokenSecret'])
    except PostError as e:
        print('Rejected: %d %s' % (e.code, e.reason))
        try:
            error = json.loads(e.read)
            error_code = error['errors'][0]['code']
            error_message = error['errors'][0]['message']
            print('Error Code %d: %s' % (error_code, error_message))
        except ValueError as e:
            print(e.read)
        sys.exit(1)

    try:
        result = json.loads(post)
        parse = parse_onetag()
        parse.feed(result['source'])
        parse.close()
        print('Tweeted successfully with twitter application named %s' % (parse.data))
    except:
        pass

    sys.exit(0)