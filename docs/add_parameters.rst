Add parameters to URL
=====================

To add parameters (query) to URL, pass a dictionary as `parameters` to the
convenient methods. The code snippet below adds parameter "key1=value1" to the
URL -- the URL becomes "http://httpbin.org/get?key1=value1"::

  Cycle.get("http://httpbin.org/get",
          parameters: ["key1": ["value1"]],
          completionHandler: {cycle, error in
              println("\(cycle.response.text)")
      })

The type of `parameter` is `Dictionary<String, String[]>`, the type of the key
is `String`, the type of the value is an array of `String`. While in most cases
the array will hold just one single value, it allows multiple values to be
associated with a single key. For example, the final URL produced by the code
below is "http://httpbin.org/get?key1=value1&key1=value1a"::

  Cycle.get("http://httpbin.org/get",
          parameters: ["key1": ["value1", "value1a"]],
          completionHandler: {cycle, error in
              println("\(cycle.response.text)")
      })

There is no such `parameters` you can pass into a `Cycle` initializer, when you
create a `Cycle` by yourself. But it's very simple to build an URL through the
helper methods provided by Cycles::

  // result: http://httpbin.org/get?key1=value1
  var URLString = MergeParametersToURL("http://httpbin.org/get", ["key1": ["value1"]])

The function `MergeParametersToURL` will correctly encode the values, join the
parameter pairs with character `&` and concatenate the following parts: the
original URL, a characher `?` and the query.

`MergeParametersToURL` also allows query string to appear in the original URL,
the method will parse the query and merge them with the new parameters. In the
code snippet below, `key2` in the original URL and `key1` in the parameters will
both appear in the final URL::

  // result: http://httpbin.org/get?key1=value1&key2=value2
  var URLString = MergeParametersToURL("http://httpbin.org/get?key2=value2", ["key1": ["value1"]])
