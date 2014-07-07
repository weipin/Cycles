Display network activity
========================

On iOS, to show network activity your app can ask the system to display a
spinning indicator in the status bar. The indicator helps the user learn that
your app is making network connections. Cycles will show/hide the indicator
for you automatically, you don't have to do anything.

Cycles does this by sharing a singleton of class `NetworkActivityIndicator`
among all the Session objects. The NetworkActivityIndicator has an internal
count starts from 0. Each time a request is sent, the NetworkActivityIndicator
increase the count by 1. Each time a response is received or ended with an error,
the NetworkActivityIndicator decrease the count by 1. The network activity will
be displayed if the count is larger than 0. The network activity will be hidden
if the count reaches 0 again.

To disable this automatic behavior, you set the property `networkActivityIndicator`
of the Session objects to nil::

  Session.defaultSession().networkActivityIndicator = nil

.. note:: If your app only uses the default Session, the code snippet above is
          sufficient. But if there are other Session objects being used, don't
          forget to configure the networkActivityIndicator of these objects as
          well.
