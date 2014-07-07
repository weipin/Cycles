Customize retry policy
======================

Cycles will :ref:`auto_retry_label` a request in certain conditions. If your needs
beyond the default implementation, you can customize the retry policy through
the delegate of the Session. Steps:

#. Create a class conforms to SessionDelegate.
#. Implement this optional method for the class::

       sessionShouldRetryCycle(session: Session, cycle: Cycle, error: NSError?) -> Bool;

#. Create an object of this class and assign this object as the property `delegate`
   of the Session.

::

  class SessionDelegateNoneRetry : SessionDelegate {
      func sessionShouldRetryCycle(session: Session, cycle: Cycle, error: NSError?) -> Bool {
          return false
      }
  }

  let TheDelegate = SessionDelegateNoneRetry()

  func foo() {
      var URL = NSURL(string: "http://127.0.0.1:8000/test/echo?code=500")
      var cycle = Cycle(requestURL: URL)
      cycle.solicited = true
      // Make sure TheDelegate exist until the response is received
      cycle.session.delegate = TheDelegate

      cycle.start { (cycle, error) in
          println("\(cycle.response.statusCode)") // 500
      }
  }

  foo()

In this code snippet, the method `sessionShouldRetryCycle` of
SessionDelegateNoneRetry always returns false, meaning that no retry will be
attempted in any case. Also, a SessionDelegateNoneRetry is created and assigned
to a Session as the property `delegate`.

.. note:: The property `delegate` is a weak reference. Make sure the object it
          references to exist until the response is received.
