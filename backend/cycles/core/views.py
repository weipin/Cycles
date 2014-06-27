import cgi
import base64
from hashlib import sha1
import hmac
import time
import uuid

import python_digest

from django.conf import settings
from django.shortcuts import render
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt

# Create your views here.

def hello(request):
    return HttpResponse('Hello World')
    
def echo(request):
    delay = float(request.GET.get('delay', 0.0))
    if delay > 0.0:
        time.sleep(delay)
        
    code = int(request.GET.get('code', 200))
    content = request.GET.get('content', '')
    encoding = request.GET.get('encoding', None)
    
    if encoding is not None:
        content = content.encode(encoding)
    response = HttpResponse(content=content, status=code)
    
    headers = request.GET.getlist('header', None)    
    for header in headers:
        i = header.find(':')
        if i >= 0:
            key = header[:i]
            value = header[i+1:]
            response[key] = value
    
    return response

def dumpmeta(request):
    str = ''
    for k, v in request.META.iteritems():
        str += '%s=%s\r\n' % (k, v)
    
    return HttpResponse(str)

@csrf_exempt
def dumpupload(request):
    return HttpResponse(request.body)
    
def _basic_unauthenticated(request):
    response = HttpResponse('', status=401)
    response['WWW-Authenticate'] = 'Basic Realm="DEV"'
    return response    
    
def hello_with_basic_auth(request):
    auth = request.META.get('HTTP_AUTHORIZATION', None)
    if auth is None:
        return _basic_unauthenticated(request)
        
    try:
        method, data = auth.split()
        if 'basic' != method.lower():
            return _basic_unauthenticated(request)
        data = base64.b64decode(data).decode('utf-8')
    except:
        return _basic_unauthenticated(request)
    
    ary = data.split(':', 1)
    if len(ary) != 2:
        return _basic_unauthenticated(request)

    username = ary[0]
    password = ary[1]
    if username == 'test' and password == '12345':
        return HttpResponse('Hello World')

    return _basic_unauthenticated(request)

def _digest_unauthenticated(request):
    response = HttpResponse('', status=401)
    u = uuid.uuid4()
    o = hmac.new(str(u).encode('utf-8'), digestmod=sha1).hexdigest()
    s = python_digest.build_digest_challenge(
            timestamp=time.time(),
            secret=getattr(settings, 'SECRET_KEY', ''),
            realm='DEV',
            opaque=o,
            stale=False
        )
    response['WWW-Authenticate'] = s
    
    return response    
    
def hello_with_digest_auth(request):
    auth = request.META.get('HTTP_AUTHORIZATION', None)
    if auth is None:
        return _digest_unauthenticated(request)
        
    try:
        method, data = auth.split(' ', 1)
        if 'digest' != method.lower():
            return _digest_unauthenticated(request)
    except:
        raise
        return _digest_unauthenticated(request)
    
    digest_response = python_digest.parse_digest_credentials(auth)
    expected = python_digest.calculate_request_digest(
        request.method,
        python_digest.calculate_partial_digest(digest_response.username, 'DEV', '12345'),
        digest_response)

    if digest_response.response != expected:
        return _digest_unauthenticated(request)

    return HttpResponse('Hello World')



    
    