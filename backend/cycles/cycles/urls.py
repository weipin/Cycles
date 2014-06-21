from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
    url(r'^test/', include('core.urls')),
    
)
