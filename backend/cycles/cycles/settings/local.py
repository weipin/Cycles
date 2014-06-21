from os.path import join, normpath

from base import *


DEBUG = True
TEMPLATE_DEBUG = DEBUG


EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'


DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': normpath(join(DJANGO_ROOT, 'default.db')),
        'USER': '',
        'PASSWORD': '',
        'HOST': '',
        'PORT': '',
    }
}


CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
    }
}
