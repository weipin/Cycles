Custom headers
==============

The convenient methods don't support custom headers. You have to create a
`Cycle` manually to add headers::

  var URL = NSURL(string: "https://github.com/timeline.json")
  var cycle = Cycle(requestURL: URL)
  cycle.request.core.setValue("Swift-Cycles/0.1.0", forHTTPHeaderField: "User-Agent")
