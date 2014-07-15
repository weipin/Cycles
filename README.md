Cycles
====

[Cycles is in early development, not fully tested. It's also iOS only for now.]

** Xcode 6.0 Beta3 (6A254o) is REQUIRED **

Cycles is a HTTP library written in Swift, inspired by [AFNetworking](http://afnetworking.com/)
and [Requests](http://docs.python-requests.org/). The target of Cycles is to
free you from writing glue code around the NSURLSession classes.

```
Cycle.get("https://api.github.com/user/",
    requestProcessors: [BasicAuthProcessor(username: "user", password: "pass")],
    responseProcessors: [JSONProcessor()],
    completionHandler: { (cycle, error) in
        println("\(cycle.response.statusCode)") // 200
        var header = cycle.response.valueForHTTPHeaderField("content-type")
        println("\(header)") // application/json; charset=utf-8
        println("\(cycle.response.textEncoding)") // 4
        println("\(cycle.response.text)") // {"login":"user","id":3 ...
        println("\(cycle.response.object)") // {"avatar_url" = ...
    })
```

Cycles offers a set of higher-level objects. With these objects, there is no
need to manually build query strings, or to create collection objects from
JSON response. More importantly, Cycles is designed in a way to help you build
HTTP functionality into your model layer. Also, properties like `solicited`
encourage you to build delightful user experiences.

Making HTTP requests is simple with Cycles. Here is a handful of examples:

Send a GET request.
```
Cycle.get("http://www.apple.com", completionHandler: { (cycle, error) in
        println("\(cycle.response.text)") // <!DOCTYPE html>...
    })
```

POST collection objects with JSON format and receive collection objects from
JSON response.
```
Cycle.post("http://127.0.0.1:8000/test/dumpupload/",
    requestObject: NSDictionary(object: "v1", forKey: "k1"),
    requestProcessors: [JSONProcessor()],
    responseProcessors: [JSONProcessor()],
    completionHandler: {(cycle, error) in
        println("\(cycle.response.object)") // { k1 = v1; }
    })
```


Upload a NSData
```
Cycle.upload("http://127.0.0.1:8000/test/dumpupload/",
    data: "Hello World".dataUsingEncoding(NSUTF8StringEncoding),
    completionHandler: {
        (cycle, error) in
        println("\(cycle.response.text)") // Hello World
    })
```

Download a file
```
Cycle.download("http://127.0.0.1:8000/test/echo?content=helloworld",
    downloadFileHandler: {(cycle, location) in
        var content = NSString(contentsOfURL: location,
                        encoding: NSUTF8StringEncoding, error: nil)
        println("\(content)") // helloworld
    },
    completionHandler: {(cycle, error) in
        println("\(cycle.response.statusCode)") // 200
    })
```

For more information, please [read the documentation](http://cycles.readthedocs.org/).


Installation
====
Cycles hasn't been packaged as a framework for now. You will have to add the
[source files](https://github.com/weipin/Cycles/tree/master/source) to your
own project to use Cycles.

- Add all files in the "source" folder to your project.

Support
====
Please use the [issues system](https://github.com/weipin/Cycles/issues). We look
forward to hearing your thoughts on the project.

Known Issues
====
1. Namespace. If Cycles were written in Objective-C, a prefix will be applied to
   the classes and global variables. Swift, on the other hand, is supposed to
   have namespaces. While it's uncertain how to distinguish between identifiers
   with the same exact name in Swift, identifiers in Cycles have no prefix.  
1. UIAlertController's presenting view controller. BasicAuthentication can
   present an alert view for user to input username and password. This is
   achieved by creating a UIAlertController with username and password fields.
   Unlike UIAlertView, before a controller can be presented, a presenting view
   controller is required. That's the purpose of BasicAuthentication's property
   `presentingViewController`. The problem is that if the presenting view
   controller isn't visible, or if there is a modal controller already
   presented, the UIAlertController won't be displayed. It might be necessary
   to switch back to UIViewAlert, but "showing" a UIAlertView keeps crashing
   the app at the time the code was written.


License
====
Cycles is released under the MIT license. See [LICENSE.md](https://github.com/weipin/Cycles/blob/master/LICENSE).
