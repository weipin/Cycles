Upload
======

Uploading a NSData or a file is easy through the upload convenient methods.

Upload a NSData::

  Cycle.upload("http://127.0.0.1:8000/test/dumpupload/",
      data: "Hello World".dataUsingEncoding(NSUTF8StringEncoding),
      completionHandler: {
          (cycle, error) in
          println("\(cycle.response.text)") // Hello World
      })

Upload a file::

  Cycle.upload("http://127.0.0.1:8000/test/dumpupload/",
      file: NSURL(string: "/PATH/TO/FILE"),
      completionHandler: {
          (cycle, error) in
          println("\(cycle.response.text)") // content of file
      })

To obtain upload progress information, pass a `CycleDidSendBodyDataHandler` as
parameter `didSendBodyDataHandler`::

  Cycle.upload("http://127.0.0.1:8000/test/dumpupload/",
      file: NSURL(string: ""),
      didSendBodyDataHandler: {
          (cycle, bytesSent, totalBytesSent, totalBytesExpectedToSend) in
          // handle progress
      },
      completionHandler: {
          (cycle, error) in
          println("\(cycle.response.text)") // Hello World
      })
