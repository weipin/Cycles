Cycles
====

[Cycles is in early development, not fully tested. It's also iOS only for now.]

** Xcode 6.0 Beta5 (6A279r) REQUIRED **

Cycles is a HTTP library written in Swift. The target of Cycles is to
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

- [Visit swift-cycles.org](http://www.swift-cycles.org).
- [Read through the documentation](http://docs.swift-cycles.org) to learn what Cycles can do.

Installation
====
Cycles hasn't been packaged as a framework for now. You will have to add the
[source files](https://github.com/weipin/Cycles/tree/master/source) to your
own project to use Cycles.

- Add all files in the "source" folder to your project.

License
====
Cycles is released under the MIT license. See [LICENSE.md](https://github.com/weipin/Cycles/blob/master/LICENSE).
