Receive Response
================

Response status code
--------------------

Once a Cycle successfully retrieves the content, you can check the response status
code through the property `statusCode` of Response::

  cycle.response.statusCode

`statusCode` is a `Computed Property`_ which obtains its value from a
`NSHTTPURLResponse`.

.. _`Computed Property`: https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Properties.html#//apple_ref/doc/uid/TP40014097-CH14-XID_329

Response content
----------------

Once a Cycle successfully retrieves the content, you can obtain the response content
through property `text` of Response::

  println("\(cycle.response.text)") // Hello World

Property `text` is a `String` which is created from response data (property
`data` of Response, a NSData). To properly create the String, the encoding of the
content is required. The Response will try to find an encoding through the HTTP
headers first. If not find, response data will be looked through to guess the
encoding. There is one exception -- if there is no charset in the headers and
the Content-Type contains "text", the encoding will be defaults to "ISO-8859-1",
according to RFC 2616, 3.7.1.

Response headers
----------------

Once a Cycle successfully retrieves the content, you can check the response headers
through the property `headers` of Response::

  var value = cycle.response.headers!.objectForKey("Content-Type") as String
  println("\(value)") // application/json

`headers` is a Computed Property which obtains its value from a `NSHTTPURLResponse`.
The value is a NSDictionary.

The code above has two problems:

* The code isn't simple enough for such a small and common task.
* Fetching a header like this isn't case-insensitive.

The ideal way to obtain a header is to invoke method `valueForHTTPHeaderField` of
Response. Accessing a header through `valueForHTTPHeaderField` is case-insensitive
and the syntax is simpler::

  if let value = cycle.response.valueForHTTPHeaderField("content-type") {
      println("\(value)")
  }

Response error
--------------

To check if there is any error happens, examine the argument `error` of
`completionHandler`. The error can be caused by network connection (NSURLErrorDomain)
or the Cycles objects (CycleErrorDomain) or other reasons.

Receive JSON response
---------------------

For a JSON response, you will want to convert the NSData back into a collection
object. You can ask Cycles do the job for your by creating a JSONProcessor, put
it into an array and pass the array as parameter `responseProcessors`::

  Cycle.post("http://127.0.0.1:8000/test/dumpupload/",
      requestObject: NSDictionary(object: "v1", forKey: "k1"),
      requestProcessors: [JSONProcessor()],
      responseProcessors: [JSONProcessor()],
      completionHandler: {(cycle, error) in
      })

Cycles will convert the response data into a collection object through the
JSONProcessor and assign the object to the property `object` of Response.

Receive response with processors
--------------------------------

Like Request objects, Response objects may also need some extra work before your
app can use the content. Take "Receive JSON response" as an example, following
tasks need to be taken care of:

* Create a collection object from response content with JSON format.
* Assign the collection object to the property `object` of Response.

With Cycles, you can also use Processor objects to complete such tasks. Each
subclass of Processor can handle a certain type of response content and prepare
the Response for you. A `Cycle` accepts an array of Processor objects as property
`responseProcessors`. After a response is received, each Processor object in the
responseProcessors will be given an opportunity to process the Response.
