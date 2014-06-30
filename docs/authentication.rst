Authentication
==============

There are two approaches for handing authentication. One is provided by the URL
loading system through classes like `NSURLCredential`, `NSURLProtectionSpace`,
`NSURLAuthenticationChallenge`, etc. The other is to prepare the request manually
or through Processor objects.

Authentication through URL loading system
-----------------------------------------

To add authentication support through URL loading system, you can create an
object of Authentication subclass, like BasicAuthentication. Add this
Authentication object in an array and pass it to the convenient method as
parameter `authentications`, or assign the array to property `authentications`
if you are creating the `Cycle` manually::

  var auth = BasicAuthentication(username: "test", password: "12345")
  Cycle.get("http://127.0.0.1:8000/test/hello_with_basic_auth",
      authentications: [auth],
      completionHandler: {
          (cycle, error) in
          println("\(cycle.response.text)") // Hello World
      })

The BasicAuthentication object can handle three authentication methods: Basic,
Digest and NTLM.


Prepare request manually for authentication
-------------------------------------------

There are authentication methods the Authentication classes don't support. And
in some situations, preparing requests manually is the only option. Take GitHub
API's Basic Authentication as an example, for unauthenticated requests, the
GitHub API responds with `404 Not Found`, instead of `401 Unauthorized`. In such
case, URL loading system's authentication routes won't be triggered.

The solution is to manually craft the `Authorization` header. Using Processor
objects can be a perfect choice for this task::

  Cycle.get("https://api.github.com/user/",
      requestProcessors: [BasicAuthProcessor(username: "user", password: "pass")],
      responseProcessors: [JSONProcessor()],
      completionHandler: { (cycle, error) in
          println("\(cycle.response.statusCode)") // 200
          var header = cycle.response.valueForHTTPHeaderField("content-type")
          println("\(header)") // application/json; charset=utf-8
          println("\(cycle.response.textEncoding)") // 4
          println("\(cycle.response.text)") // {"login":"user","id":3 ...
          println("\(cycle.response.object)") // {"avatar_url" = ...
      })

In this code snippet, a BasicAuthProcessor object was created and passed into
the convenient method as parameter `requestProcessors`. Before the request is
sent, the BasicAuthProcessor object will craft and set the `Authorization`
header.
