Operation queues
================

A `Session` object has two queues: `delegateQueue` and `workerQueue`.
The `delegateQueue` is for scheduling the handlers, which include all of the
`Cycle` handlers  like `completionHandler`. The default value of
`delegateQueue` is the main queue. The `workerQueue` is for scheduling tasks
that may require some time to finish. For example, executing Processor objects
will be scheduled in the `workerQueue`. The default value of the `workerQueue`
is a new NSOperationQueue, so tasks will be executed off the main thread.

The `delegateQueue` of `Session` will also be passed as parameter `queue` to
create a NSURLSession object, so this `delegateQueue` will also be the queue for
scheduling NSURLSession's delegate calls and completion handlers.
