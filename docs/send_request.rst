Send request
============

POST raw data
-------------

You can post raw data through both approaches: 1) the convenient method of
`Cycle`. 2) create, configure a `Cycle` object and then "start".

Here is an example of using the convenient method::

  Cycle.post("http://127.0.0.1:8000/test/dumpupload/",
      requestObject: "Hello World".dataUsingEncoding(NSUTF8StringEncoding),
      requestProcessors: [DataProcessor()],
      completionHandler: {
          (cycle, error) in
          println("\(cycle.response.text)") // Hello World
      })

In this code snippet, a NSData is past as parameter `requestObject` and a
`DataProcessor` is created and passed as `requestProcessors` in an array.
The connection between `requestObject` and `requestProcessors` will be
explained in :ref:`object_and_data_label`.

Here is an example of creating a `Cycle` manually. You create the `Cycle`
and assign a NSData to the property `data` of the Request, which is property
`request` of the `Cycle`::

  var URL = NSURL(string: "http://127.0.0.1:8000/test/dumpupload/")
  var cycle = Cycle(requestURL: URL, requestMethod: "POST")
  cycle.request.data = "Hello World".dataUsingEncoding(NSUTF8StringEncoding)
  cycle.start {
      (cycle, error) in
      println("\(cycle.response.text)") // Hello World
  }


Send JSON request
-----------------

It's common to send request with JSON content. To POST such requests through
convenient methods, you need to do two things:

* Prepare a collection object (a NSDictionary in most cases) and pass the object
  as parameter `requestObject`.
* Create a JSONProcessor, put it into an array and pass the array as parameter
  `requestProcessors`.

::

  Cycle.post("http://127.0.0.1:8000/test/dumpupload/",
      requestObject: NSDictionary(object: "v1", forKey: "k1"),
      requestProcessors: [JSONProcessor()],
      completionHandler: {(cycle, error) in
      })

Cycles will convert the NSDictionary into a NSData with JSON format through the
JSONProcessor and assign the NSData to the property `data` of Request. The
JSONProcessor will also set header "Content-Type" as "application/json".

Send request with processors
----------------------------

Before a request can be sent, there may be extra preparation work. Take "Send
a JSON request" as an example, following tasks need to be taken care of:

* Create a NSData with JSON format from a collection object.
* Assign the NSData to the property `data` of Request.
* Set header "Content-Type" as "application/json".

With Cycles, you can use Processor objects to complete such tasks. Each subclass
of Processor can handle a certain type of object and prepare the Request for you.
A `Cycle` accepts an array of Processor objects as property `requestProcessors`.
Before a request is being sent, each Processor object in the requestProcessors
will be given an opportunity to process the Request.
