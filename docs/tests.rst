Tests
=====

Cycles has its own backend built with Django_ for tests. The backend files can
be found in the "backend folder"_. If you want to run the tests on your
environment, you need to setup a Django environment and start the backend
instance.

Setup the Django environment
----------------------------

Assume virtualenv_ is installed.

Prepare the environment::

  cd backend
  virtualenv ~/ENV/cycles
  source ~/ENV/cycles/bin/activate
  pip install -r requirements.txt

Run the backend instance::

  cd cycles
  python manage.py runserver


Run the tests
-------------

In the CyclesTouch folder, open CyclesTouch.xcodeproj with Xcode 6.0. Choose
Test from the Project menu.


.. _Django: https://www.djangoproject.com/
.. _"backend folder": https://github.com/weipin/Cycles/tree/master/backend
.. _virtualenv: http://virtualenv.readthedocs.org/en/latest/virtualenv.html
