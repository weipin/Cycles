Service profile
===============

A Service profile is a `Property Lists`_ file which describes a Service for base 
URL, endpoints, etc. Here is a `profile example`_ of the GH service.

.. _`Property Lists`: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/PropertyLists/Introduction/Introduction.html.
.. _`profile example`: https://github.com/weipin/Cycles/blob/master/CyclesTouch/GH.plist


Assign a profile to the Service
-------------------------------

"One Service subclass pairs one physical Profile file" isn't required but a 
convention. The convention simplifies the management of the Service subclasses, 
and can make creating a Service easy.

A profile is nothing but a dictionary. As long as the profile is valid, you can 
assign the dictionary to the property `profile` of the Service. The dictionary 
can be passed to the initializer when the Session is being created, or assigned 
after the creation to replace the existing one.

In such case, how to create the profile dictionary is completely under your 
control. You can create it from code, from another local file or a remote file 
fetched from web.

Pass the profile through initializer.
```
// dict is a Dictionary with valid profile data
var session = GH(profile: dict)
```

Replace the existing profile.
```
session.profile = dict
```

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
return `false` and print error messages in the console if the profile does not 
valid.

You may want to verify profiles only in the "debug mode" of the application. 
But if the data is downloaded from web or other unsafe sources, verifying and 
rejecting the invalid ones sounds a good idea.

