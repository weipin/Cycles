Service base URL
================

With the ability of switching base URL freely, class Service makes testing in 
different environments easy. For example, if you want to run the app against 
the local development environment, you can change the baseURL to point to the 
local IP:

```
service.baseURL = "http://127.0.0.1:8000"
```

.. note:: Consider use the host part of the URLs as base URL. "http://www.someapp.com" 
might be better than "http://www.someapp.com/api/v1/" as a base URL.