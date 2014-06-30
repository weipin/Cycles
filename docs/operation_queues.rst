Operation queues
================

A `Session` object has two queues. The `delegateQueue` is for scheduling the
handlers, which include all of the `Cycle` handlers  like the `completionHandler`.
The default value of `delegateQueue` is the main queue. The `workerQueue` is for
scheduling tasks that may require some time to finish. Executing Processor
objects will be scheduled in the `workerQueue`. The default value of the
`workerQueue` is a new NSOperationQueue, so tasks will be executed off the main
thread.

The `delegateQueue` of `Session` will also be passed as `queue` to create a
NSURLSession object, so this `delegateQueue` will also be the queue for scheduling
NSURLSession's delegate calls and completion handlers. One difference is that
for NSURLSession's `queue`, if nil, a serial operation queue will be created and
handlers will be called off the main thread. Because it's common to execute user
interface code in the handlers, use main queue as the default value can be
convenient.
