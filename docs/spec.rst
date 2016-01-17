ev3dev Language Wrapper Specification
=====================================

This is an unofficial specification that defines a unified interface for
language wrappers to expose the ev3dev_ device APIs.

.. _ev3dev: http://www.ev3dev.org

.. rubric:: General Notes

Because this specification is meant to be implemented in multiple languages,
the specific naming conventions of properties, methods and classes are not
defined here. Depending on the language, names will be slightly different (ex.
"touchSensor" or "TouchSensor" or "touch-sensor") so that they fit the
language's naming conventions.

Some concepts that apply to multiple classes are described as "abstracts".
These abstract sections explain how the class should handle specific
situations, and do not necessarily translate in to their own class in the
wrapper.

.. rubric:: Implementation Notes (important)

- File access. There should be one class that is used or inherited from in all
  other classes that need to access object properties via file I/O. This class
  should check paths for validity, do basic error checking, and generally
  implement as much of the core I/O functionality as possible.
- Errors. All file access and other error-prone calls should be wrapped with
  error handling. If an error thrown by an external call is fatal, the wrapper
  should throw an error for the caller that states the error and gives some
  insight in to what actually happened.
- Naming conventions. All names should follow the language's naming
  conventions. Keep the names consistent, so that users can easily find what
  they want.
- Attribute types. ``int`` and ``string`` attributes are read-write files
  containing a single value that is representable either as an integer or as a
  single word. A ``string array`` attribute is a readonly file that contains
  space-separated list of words, where each word is a possible value of some
  other ``string`` atribute.  And a ``string selector`` attribute is a
  read-write file that contains space-separated list of possible values, where
  the currently selected value is enclosed in square brackets. Another value
  may be selected by writing a single word to the file.

.. rubric:: Contents

.. toctree::
    :maxdepth: 2

    classes
    sensors
    constants

.. rubric:: Compatibility table

============ ==============================
Spec Version Fully Supported Kernel Version
============ ==============================
``v0.9.1``   ``v3.16.1-7-ev3dev``
``v0.9.2``   ``v3.16.7-ckt10-4-ev3dev``
``v1.0.0``   ``v3.16.7-ckt21-9-ev3dev``
============ ==============================

