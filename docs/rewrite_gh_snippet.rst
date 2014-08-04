Rewrite the GH code snippet with Service
========================================

Remember the GH code snippet to request user information (`api.github.com/user`)?
This section continues using GH as example.

::

    Cycle.get("https://api.github.com/user/",
        requestProcessors: [BasicAuthProcessor(username: "user", password: "pass")],
        responseProcessors: [JSONProcessor()],
        completionHandler: { (cycle, error) in
          // ...
        })

Use `Service`, the code can be simplified as::

  var service = GH()
  service.requestResource("user",
     completionHandler: { (cycle, error) in
       // ...
     })

.. note:: GH is a Service subclass. It requires a Profile to work properly. 
          we will discuss Profile in the following sections.


Base URL, URI templates, request processors and response processors are the 
attributes that various GH cycles share. These attributes are provided by the 
Service subclass (GH and its Profile) so you don't have to. You can also set 
other attributes, like HTTP headers, in class GH which isn't revealed here.

Besides the ability of setting a base URL (property `baseURL` of Service), the 
benefit of using a Service doesn't seem obvious in the code snippet above. But 
if your app needs to interact with a set of similar "endpoints", like an API, 
using a Service subclass can be convenient because you don't have to repeat 
yourself. Here is another code snippet for GitHub searching::

  var service = GH()
  service.requestResource("search", URIValues = ["q": "cycles"],
     completionHandler: { (cycle, error) in
         println("\(cycle.response.object)")
     })

You need class `GH`_ and profile `GH.plist`_ to make the code snippets above work. 
The following sections explains how to create a Service subclass and its profile.

.. _`GH`: https://github.com/weipin/Cycles/blob/master/CyclesTouch/GH.swift
.. _`GH.plist`: https://github.com/weipin/Cycles/blob/master/CyclesTouch/GH.plist

.. note:: While we use GitHub API as examples, this project isn't affiliated with GitHub.
