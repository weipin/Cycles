Custom headers
==============

The convenient methods do not support custom headers. You have to create a
`Cycle` to add headers::

  var URL = NSURL(string: "https://github.com/timeline.json")
  var cycle = Cycle(requestURL: URL)
  cycle.request.core.setValue("Cycles/0.01", forHTTPHeaderField: "User-Agent")
