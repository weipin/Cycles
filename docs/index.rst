.. Cycles documentation master file, created by
   sphinx-quickstart on Sat Jun 28 08:56:03 2014.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to Cycles!
==================

Cycles is a HTTP library written in Swift. The target of Cycles is to free you 
from writing glue code around the NSURLSession classes::

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

Cycles offers a set of higher-level objects. With these objects, there is no
need to manually build query strings, or to create collection objects from
JSON response. More importantly, Cycles is designed in a way to help you
build HTTP functionality into your model layer. Also, properties like
`solicited` encourage you to build delightful user experiences.

Introduction
------------

.. toctree::
    :maxdepth: 2

    make_a_request
    install
    architecture

Quickstart
----------

.. toctree::
    :maxdepth: 2

    start_a_cycle
    custom_headers
    cancellation
    add_parameters
    send_request
    receive_response
    object_and_data
    create_your_own_processors
    upload
    download
    auto_retry
    timeout
    solicited_request
    session
    operation_queues
    authentication
    restart

Service
-------

`Service` is a higher level class you can use to manage Cycles with similar 
attributes.

.. toctree::
    :maxdepth: 2

    rewrite_gh_snippet
    service_subclass
    service_profile
    service_base_url
    service_methods
    
Advanced Usage
--------------

.. toctree::
    :maxdepth: 2

    display_network_activity
    retry_policy
    http_status_error
    preserved_request_state
    tests    