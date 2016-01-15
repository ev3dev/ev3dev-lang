Constants / Enums
-----------------

Due to the inherent differences between the various languages that we support
here, the enums listed below can also be declared as global constants.

Ports
#####

.. py:data:: INPUT_AUTO

    Automatic input selection. Value is instance-specific (see below for
    details)


.. py:data:: OUTPUT_AUTO

    Automatic output selection. Value is instance-specific (see below for
    details)

.. py:data:: INPUT_1

    Sensor port 1, ``"in1"``

.. py:data:: INPUT_2

    Sensor port 2,, ``"in2"``

.. py:data:: INPUT_3

    Sensor port 3, ``"in3"``

.. py:data:: INPUT_4

    Sensor port 4, ``"in4"``

.. py:data:: OUTPUT_A

    Motor port A, ``"outA"``

.. py:data:: OUTPUT_B

    Motor port B, ``"outB"``

.. py:data:: OUTPUT_C

    Motor port C, ``"outC"``

.. py:data:: OUTPUT_D

    Motor port D, ``"outD"``

.. note::

    The values for the ``*_AUTO`` constants can be chosen by the
    implementation.  They can have any value that signifies an auto-search.
