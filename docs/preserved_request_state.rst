Preserved request state
=======================

You can ask a Session to apply specified states for each request being sent
through. "States" can be HTTP headers or query parameters. A practical sample
can explain this feature better.

Tastypie_ is a fine web service API framework for Django, which can be used to
build REST-style interfaces quickly and easily. Tastypie provides an
authentication component to validate user access. There are several built-in
authentication options like HTTP Basic Auth and OAuth, but we will use its
`ApiKeyAuthentication`_ for this sample.

.. _Tastypie: http://tastypieapi.org/

To use this mechanism (ApiKeyAuthentication), the end user can either specify
an Authorization header or pass the username/api_key combination as GET/POST
parameters. Examples::

  # As a header
  # Format is ``Authorization: ApiKey <username>:<api_key>
  Authorization: ApiKey daniel:204db7bcfafb2deb7506b89eb3b9b715b09905c8

  # As GET params
  http://127.0.0.1:8000/api/v1/entries/?username=daniel&api_key=204db7bcfafb2deb7506b89eb3b9b715b09905c8


Assume we have already obtained the username as variable `username` and the api_key
as variable `APIKey`, we can ask a Session to apply the credential for us to every
each request it sends.

As a header::

  let value = "ApiKey \(username):\(APIKey)"
  var session = Session.defaultSession()
  session.setPreservedHTTPHeaderField("Authorization", value: value)

As GET parameters::

  var session = Session.defaultSession()
  session.setPreservedHTTPQueryParameter("username", value: [username])
  session.setPreservedHTTPQueryParameter("api_key", value: [APIKey])

Now for every each request associates with the default Session, the header
or the parameters will be set properly before the request can be sent.

.. _`ApiKeyAuthentication`: https://django-tastypie.readthedocs.org/en/latest/authentication.html#apikeyauthentication

Save and load
-------------
The user won't be happy if your app keeps prompting a sign in after each
relaunch. The Session needs a way to archive the states and load that states
back into the Session.

To archive the states, call the method `dataForPreservedState` of Session. The
method returns a NSData which can be easily stored in a NSUserDefaults or a file::

  var session = Session.defaultSession()
  var error: NSError?
  var data = session.dataForPreservedState(&error)
  // Store data in a NSUserDefaults or a file
  // ...

The next time your app launches, load the states back into the Session::

  // Obtain the NSData from a NSUserDefaults or a file
  // var data = ...
  var session = Session.defaultSession()
  var error: NSError?
  session.loadPreservedStateFromData(data, error: &error)

.. hint:: There is nothing prevents you from managing the states all by yourself
          and set up the requests manually. You can also create Processor
          subclasses to make the task easier. But at the same time, you may find
          Session's "Preserved Request State" feature convenient in certain
          situations.
