Install
=======

Get the code
------------

Cycles is open source, and the code is `available on github`_. There is no demo
project for now, files for Cycles can be found in the `source folder`_.

.. _`available on github`: https://github.com/weipin/Cycles
.. _`source folder`: https://github.com/weipin/Cycles/tree/master/source

Install manually
----------------

Cycles hasn't been packaged as frameworks for now. You will have to add the source files to your own project to use Cycles.

* Except the Objective-C files (Utils.h and Utils.m), add all files in the
  "source" folder to your project.
* Add Objective-C files (Utils.h and Utils.m) to your project. If Xcode asks if
  you want to configure an Objective-C bridging header, select Yes. If Xcode
  keeps crashing, try copy the files to your project's folder and then add.
* In the bridging header file Xcode created for you (filename like
  PROJECT-Bridging-Header.h), import the Objective-C header files.

::

  #import "Utils.h"
