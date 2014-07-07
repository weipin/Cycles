Error originates from HTTP status
=================================

By default, Cycles treats a response with HTTP status above 400 (including 400)
as a failure -- a NSError object will be created and passed as parameter `error`
to the `completionHandler`::

  Cycle.get("http://www.apple.com/404/",
      completionHandler: {cycle, error in
          println("\(error!.domain)") // CycleError
          println("\(CycleErrorCode.fromRaw(error!.code))") // StatusCodeSeemsToHaveErred
          println("\(cycle.response.statusCode)") // 404
      })

This behavior helps you write less code since you don't have to examine status code
for "logic errors". And if you handle the NSError objects in certain ways like
displaying a visual clue, these "logic errors" will also be presented which is
good in most cases.

If you want to handle the status code all by yourself (no longer creates NSError
objects for status above 400), you can change the behavior through the delegate
of the Session. Steps:

#. Create a class conforms to SessionDelegate.
#. Implement this optional method for the class::

    sessionShouldTreatStatusCodeAsFailure(session: Session, status: Int) -> Bool;

#. Create an object of this class and assign this object as the property `delegate`
   of the Session.

::

  class SessionDelegateNoneStatusFailure : SessionDelegate {
      func sessionShouldTreatStatusCodeAsFailure(session: Session, status: Int) -> Bool {
          return false
      }
  }

  let TheDelegate = SessionDelegateNoneStatusFailure()

  func foo() {
    var URL = tu_("http://www.apple.com/404/")
    var cycle = Cycle(requestURL: URL)
    // Make sure TheDelegate exist until the response is received
    cycle.session.delegate = TheDelegate

    cycle.start { (cycle, error) in
      if !error {
        println("none error") // none error
      }
      println("\(cycle.response.statusCode)") // 404
    }
  }

  foo()

In this code snippet, the method `sessionShouldTreatStatusCodeAsFailure` of
SessionDelegateNoneStatusFailure always returns false, meaning that no status
code will be treated as error. Also, a SessionDelegateNoneStatusFailure is
created and assigned to a Session as the property `delegate`.

.. note:: The property `delegate` is a weak reference. Make sure the object it
          references to exist until the response is received.
