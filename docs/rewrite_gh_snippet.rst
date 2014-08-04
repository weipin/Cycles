Rewrite the GH snippet with `Service`
=====================================

Remember the GH snippet to request user information (`api.github.com/user`)?

```
Cycle.get("https://api.github.com/user/",
    requestProcessors: [BasicAuthProcessor(username: "user", password: "pass")],
    responseProcessors: [JSONProcessor()],
    completionHandler: { (cycle, error) in
      // ...
    })
```

Use `Service`, the code can be simplified as:

```
var service = GH()
service.requestResource("user",
   completionHandler: { (cycle, error) in
     // ...
   })
```

.. note:: GH is a Service subclass. It also requires a Profile to work properly. 
we will discuss Profile in the following sections.


The base URL, URI templates, request processors and response processors are the 
attributes that various `GH` cycles share. These attributes are provided by the 
Service subclass (`GH` + its Profile file)so you don't have to in this code 
snippet. You can also set other attributes, like HTTP headers, in class GH 
which isn't revealed here.

Besides the ability of setting a base URL (property `baseURL` of Service), the 
benefit of using a Service doesn't seem obvious in the code snippet above. But 
if your app need to interact with a set of similar "endpoints", like an API, 
using a Service subclass can be convenient because you don't have to repeat 
yourself. Here is another code for GitHub searching:

```
var service = GH()
service.requestResource("search", URIValues = ["q": "cycles"],
   completionHandler: { (cycle, error) in
       println("\(cycle.response.object)")
   })
```

You need class `GH`_ and profile `GH.plist`_ to make the code snippets above work. 
The following sections will explain how to create a Service subclass and its 
profile.

.. _`GH`: https://github.com/weipin/Cycles/blob/master/CyclesTouch/GH.swift
.. _`GH.plist`: https://github.com/weipin/Cycles/blob/master/CyclesTouch/GH.plist

.. note:: This project isn't affiliated with GitHub.
