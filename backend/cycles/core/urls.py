from django.conf.urls import patterns, include, url

urlpatterns = patterns('core.views',
    url(r'^hello/', 'hello', name='core_hello'),
    url(r'^echo/', 'echo', name='core_echo'),
    url(r'^dumpmeta/', 'dumpmeta', name='core_dumpmeta'),
    url(r'^dumpupload/', 'dumpupload', name='core_dumpupload'),
    url(r'^hello_with_basic_auth/', 'hello_with_basic_auth', name='core_hello_with_basic_auth'),
    url(r'^hello_with_digest_auth/', 'hello_with_digest_auth', name='core_hello_with_digest_auth'),
)
