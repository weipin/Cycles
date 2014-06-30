Architecture
============

The `Cycle` object
------------------

A `Cycle` object (instance of class `Cycle`) represents both HTTP request
and HTTP response. To send a request, a `Cycle` object will be created and
initialized. To retrieve the response content, you examine the same `Cycle`
object.

A `Cycle` object holds all the information on request and retrieved response.
You can resend a request by invoking a single method on an existing `Cycle`
object, even if it has been "used".


Thin wrappers
-------------

Some of the Cycles classes are thin wrappers around the NSURLSession classes.
These Cycles classes all have a property called `core` which points to the
underlying Cocoa object. Here is a table on the relationships::

  ============  ===================
  Cycles Class  Cocoa Class
  ============  ===================
  Cycle         NSURLSessionTask
  Request       NSMutableURLRequest
  Response      NSHTTPURLResponse
  Session       NSURLSession
  ============  ===================


Diagram
-------
::

      +------------------------------------+
      |                                    |
      |   +-----------+    +-----------+   |
      |   |           |    |           |   |
      |   |  Request  |    | Response? |   |
      |   +-----------+    +-----------+   |
      |                                    |
      |   Cycle                            |
      |                                    |
      +------------------------------------+
                         |
                         |
                   +-----------+
                   |           |
                   |  Session  |
                   +-----------+
