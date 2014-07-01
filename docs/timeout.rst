Timeout
=======

You probably don't need to worry about the timeout because Cycles will retry a
request for you. If you have a need for a custom timeout period, you can create
a NSURLSessionConfiguration, set the property `timeoutIntervalForRequest` and
`timeoutIntervalForResource`, create a Session from this `NSURLSessionConfiguration`
and use this session to create a `Cycle`. The code snippet below set the timeout
to an unrealistic value of 1.0 second. This is the code from one of the Cycles
tests::

  var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
  configuration.timeoutIntervalForRequest = 1;
  configuration.timeoutIntervalForResource = 1
  var session = Session(configuration: configuration)

  var URL = NSURL(string: "http://127.0.0.1:8000/test/echo?delay=2")
  var cycle = Cycle(requestURL: URL, session: session)
  cycle.start {(cycle, error) in
    ...
  }
