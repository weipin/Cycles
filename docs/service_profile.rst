Service profile
===============

A Service profile is a dictionary which describes a Service with base 
URL, endpoints, etc. Here is a `profile example`_ of the GH service.

.. _`profile example`: https://github.com/weipin/Cycles/blob/master/CyclesTouch/GH.plist


Use a Property Lists as profile
-------------------------------

You can store a profile in a `Property Lists`_ file and bundle the file into
the app. The Property Lists file must be named after the Service subclass name. 
For example, the default profile name of class GH must be "GH.plist".

.. _`Property Lists`: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/PropertyLists/Introduction/Introduction.html.


Assign a profile to the Service
-------------------------------

"One physical Profile pairs one Service subclass" isn't required but a 
convention. The convention simplifies the management of the Service subclasses, 
and can make creating a Service easy.

As mentioned above, a profile is nothing but a dictionary. As long as the profile 
is valid, the dictionary can be passed to the initializer when the Session is 
being created, or assigned to an existing one as property `profile`.

In such case, creating the profile dictionary is completely under your 
control. You can create it from code, from another local file or a remote file 
fetched from web.

Pass a profile through initializer::

  // dict is a Dictionary with valid profile data
  var session = GH(profile: dict)


Replace the existing profile::

  session.profile = dict


Profile specification
---------------------

The specification is simple and straightforward, see `GH.plist`_ for an example.

.. _`GH.plist`: https://github.com/weipin/Cycles/blob/master/CyclesTouch/GH.plist


============  =======  ========  =======
Key           Type     Required  Default
============  =======  ========  =======
BaseURL       String   no        ""
Resources     Array    yes       n/a
============  =======  ========  =======

And for the items of the `Resources` array:

============  =======  ========  =======
Key           Type     Required  Default
============  =======  ========  =======
Name          String   yes       n/a
URITemplate   String   yes       n/a
Method        String   no        "GET"
============  =======  ========  =======


Verifying
---------

Use the method `verifyProfile` to verify a specified profile. The method will 
return `false` and print error messages in the console if the profile isn't valid.

You may want to verify profiles only in the "debug mode" of an application. 
But if the data is downloaded from web or other unsafe sources, verifying and 
rejecting the invalid ones in the "production mode" is also necessary.

