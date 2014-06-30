Cancellation
============

To cancel a request, you need the `Cycle` object the request attached to.
If the request is issued by a convenient method, you need to store the `Cycle`
object returned from that convenient method::

  var cycle = Cycle.get("https://github.com/timeline.json", completionHandler: {
      (cycle, error) in
      // ...
  });

Call the method `func cancel(explicitly: Bool)` of `Cycle` to cancel a request.
The parameter `explicitly` indicates if the request is cancelled explicitly.
`explicitly` does not affect how the connection will be cancelled, but merely a
value to be stored in the property `explicitlyCanceling` of `Cycle`. Your app
can use this value for cancellation logic -- when the connection is cancelled,
the `completionHandler` won't be called if `explicitly` is set as `true`.
You probably want to pass `true` as `explicitly`, to address the cases that users
cancel an operation explicitly. If you pass `false`, you can still check if
the connection is cancelled by examining the argument `error` of
`completionHandler`. Here is an example::

  cycle.start(completionHandler: {(cycle, error) in
      if let e = error {
          if e.domain == NSURLErrorDomain && e.code == NSURLErrorCancelled {
              // Process cancellation
          }
      }
  })
