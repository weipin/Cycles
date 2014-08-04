Subclass Service
================

To use Service, you MUST create a Service subclass. It is designed to work this 
way. There is one method `className` you MUST override, and two methods 
`defaultSession` and `cycleDidCreateWithResourceName` you SHOULD override. Use 
the code snippet below as a template when you create a Service subclass::

  class MyService: Service {
      override class func className() -> String {
          return "MyService"
      }

      override func defaultSession() -> Session {
          return super.defaultSession()
      }

      override func cycleDidCreateWithResourceName(cycle: Cycle, name: String) {
      }

  }


Method `className` is required. You should always return the name of the class. 
The class name will be used to locate the default profile. For example, the default 
profile filename of GH will be GH.plist.

.. note:: This method weren't necessary if we had a way to obtain the name of a 
          Swift class through built-in routes. Please ping the developer if you 
          are aware of such approaches.

The method `defaultSession` is optional. The result of this method will be 
assigned to the property `session` of the Service subclass. In this method, 
you can customize the session by adding HTTP headers, setting processors, etc, 
like what GH does (you can also create and return a complete new Session with 
your own configuration)::

  override func defaultSession() -> Session {
      var session = super.defaultSession()
      session.setPreservedHTTPHeaderField("User-Agent", value: "Swift-Cycles/0.1.0")

      session.requestProcessors = [BasicAuthProcessor(username: "user", password: "pass")]
      session.responseProcessors = [JSONProcessor()]

      return session
  } 

The method `cycleDidCreateWithResourceName` is optional. You can use this method 
to customize specific Cycles created by the Service. `cycleDidCreateWithResourceName` 
will be called immediately after a Cycle is created by the Service, so you can have 
a chance to customize the Cycles that don't share some of the properties with 
the common ones. For example, if there is an "endpoint" doesn't require JSON 
for both request and response, you can make an "exception" of the processors 
for it::

  override func cycleDidCreateWithResourceName(cycle: Cycle, name: String) {
      if name == "postdata" {
          cycle.requestProcessors = [DataProcessor()]
          cycle.responseProcessors = []
      }
  }

