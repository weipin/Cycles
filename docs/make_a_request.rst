Make a request
==============

You can retrieve the content of a URL through Cycles's methods in a asynchronous
manner::

  Cycle.get("https://github.com/timeline.json", completionHandler: {
      (cycle, error) in
      println("\(cycle.response.text)") // [{"created_at":"2014-06...
  });


The response can be handled in the `completionHandler` closure. The `cycle`
argument contains all the information on both request and response.

Besides "GET" method, you can send requests with other HTTP methods in similar
ways::

  Cycle.post("http://httpbin.org/post", completionHandler: {
      (cycle, error) in
  });

  Cycle.put("http://httpbin.org/put", completionHandler: {
      (cycle, error) in
  });

  Cycle.delete("http://httpbin.org/delete", completionHandler: {
      (cycle, error) in
  });

  Cycle.delete("http://httpbin.org/delete", completionHandler: {
      (cycle, error) in
  });

  Cycle.head("http://httpbin.org/get", completionHandler: {
      (cycle, error) in
  });

`completionHandler` isn't optional, because otherwise you will have no way to
obtain data from response.
