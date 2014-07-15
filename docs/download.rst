Download
========

Downloading a file is easy through the download convenient methods. Background
download isn't supported for now::

  var URLString = "http://127.0.0.1:8000/test/echo?content=helloworld"
  Cycle.download(URLString,
      downloadFileHandler: {(cycle, location) in
          var content = NSString(contentsOfURL: location, encoding: NSUTF8StringEncoding, error: nil)
          println("\(content)") // helloworld
      },
      completionHandler: {(cycle, error) in
        // check error
      })

The closure `downloadFileHandler` will be called with the URL (`location`) to a
temporary file where the downloaded content is stored. At the time
`downloadFileHandler` is called, you are guaranteed that the content has been
fetched successfully. Put your error handling code in `completionHandler`.

To obtain download progress information, pass a `CycleDidWriteBodyDataHandler` as
parameter `didWriteDataHandler`::

  var URLString = "http://127.0.0.1:8000/test/echo?content=helloworld"
  Cycle.download(URLString,
      didWriteDataHandler: {
        (cycle, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
        // handle progress
        
      },
      downloadFileHandler: {(cycle, location) in
          var content = NSString(contentsOfURL: location, encoding: NSUTF8StringEncoding, error: nil)
          println("\(content)") // helloworld
      },
      completionHandler: {(cycle, error) in
        // check error
      })
