Session
=======

Each `Cycle` references to a `Session`, which does all the heavy lifting.
Class `Session` is a thin wrapper around class `NSURLSession`.

The default session
-------------------

If you don't pass a `Session` when you create a `Cycle`, a default `Session`
will be used. The default `Session` is a singleton returned by the type method
`defaultSession` of `Session`. If you change a property of this `Session`, it
may affect all the `Cycle` objects reference this session.

Provide `Cycle` properties through Session
------------------------------------------

It's not uncommon to assign the same values of certain properties to multiple
`Cycle` objects. `Cycles` offers a way to make this task easier. For such
properties, you can assign the values to the Session and leaves the corresponding
properties of `Cycle` objects as nil. For these `Cycle` objects, the Session
objects they reference to will be used to return these values.

For example, if you set an array of Processor as property `requestProcessors` to
a Session, all the `Cycle` objects reference to this Session object will return
this array as the value of property `requestProcessors`, as long as the property
`requestProcessors` of the `Cycle` object is nil.

Here is a list of the properties that a Session can provide for a `Cycle` object:

* `requestProcessors`
* `responseProcessors`
* `authentications`

Create and use your own Session objects
---------------------------------------

You may want to create your own Session objects so the `Cycle` objects can
reference to the different ones. Creating a Session is easy, the parameters of
the initializer are all optional::

  var session = Session()

You may want to create and configure a NSURLSessionConfiguration, and pass this
`NSURLSessionConfiguration` as parameter `configuration` to create a Session::

  var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
  var session = Session(configuration: configuration)

The other two parameters `delegateQueue` and `workerQueue` will be discussed in
the next section.
