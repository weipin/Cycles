Start a Cycle
=============

Start a Cycle through convenient methods
----------------------------------------

The convenient methods can create a `Cycle` object for you and send the request
immediately. For example, to send a GET request, use this `type method`_ of `Cycle`::

  class func get(URLString: String, parameters: Dictionary<String, String[]>? = nil,
                 requestProcessors: Processor[]? = nil, responseProcessors: Processor[]? = nil,
                 authentications: Authentication[]? = nil, solicited: Bool = false,
                 completionHandler: CycleCompletionHandler) -> Cycle

::

  Cycle.get("https://github.com/timeline.json", completionHandler: {
      (cycle, error) in
      println("\(cycle.response.text)") // [{"created_at":"2014-06...
  });

There are type methods for other request types like POST, PUT, DELETE, etc.
See `Cycle+Convenience.swift`_ for a complete list.

The convenient methods provide only limited customization of networking behavior.
And the request will be sent immediately. If you have needs beyond basic URL
fetching, such as custom headers, or want to delay sending the request, you can
make requests in two separate steps. See next section for more information.

.. _`type method`: https://developer.apple.com/library/prerelease/ios/documentation/swift/conceptual/swift_programming_language/Methods.html#//apple_ref/doc/uid/TP40014097-CH15-XID_307
.. _`Cycle+Convenience.swift`: https://github.com/weipin/Cycles/blob/master/source/Cycle%2BConvenience.swift

Start a Cycle through 2 separate steps
--------------------------------------

These two steps are:

* Create and configure a `Cycle` object.
* "Start" the `Cycle` object.

Creating a `Cycle` object is simple, the only required parameter is `requestURL`::

  var URL = NSURL(string: "https://github.com/timeline.json")
  var cycle = Cycle(requestURL: URL)

There are other parameters, such as `parameters`, which will be discussed in the
following sections.

To send a HTTP request, call the method `func start(completionHandler: CycleCompletionHandler? = nil)` of `Cycle`::

  cycle.start(completionHandler: {(cycle, error) in
      // handle response
  })

You can handle the response in the `completionHandler` closure. Because
`completionHandler` is the last parameter, the code can be simplified with
Trailing Closures expression::

  cycle.start {(cycle, error) in
    // handle response
  }

You can examine the optional parameter `error` to check if the content is
fetched successfully. The error can be caused by HTTP connection, Processor
objects, HTTP status code, etc.
