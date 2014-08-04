Service base URL
================

With the ability of switching base URL, class Service makes testing in 
different environments easy. For example, if you want to run the app against 
a local development environment, you can change the baseURL as::

  service.baseURL = "http://127.0.0.1:8000"

.. hint:: Consider using the host part of the URLs as base URL. "http://www.someapp.com" 
          might be a better choice than "http://www.someapp.com/api/v1/" as a 
          base URL.