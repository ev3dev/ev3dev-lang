ev3dev language bindings
========================

This repository stores the utilities and metadata information for the
ev3dev-lang family of libraries. These libraries are easy-to-use interfaces for
the APIs that are available on `ev3dev`_-based devices.

The complete documentation is hosted at http://ev3dev-lang.readthedocs.org.

We support multiple libraries for various programming languages using a
centralized "specification" which we keep updated as kernel changes are made.
We don't have the actual library code here (see below) -- instead we use this
repo to facilitate the maintenance of our bindings.

We currently support libraries for the following languages:

- `C++`_
- `Node.js`_
- `Python`_

Each binding is written based on our central spec, so each has a uniform
interface which is kept close to the ev3dev API surface while still encouraging
language-specific enhancements.

.. _ev3dev: http://www.ev3dev.org
.. _C++: https://github.com/ddemidov/ev3dev-lang-cpp
.. _Node.js: https://github.com/wasabifan/ev3dev-lang-js
.. _Python: https://github.com/rhempel/ev3dev-lang-python
