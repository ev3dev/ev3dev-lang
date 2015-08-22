.. ev3dev documentation master file, created by
   sphinx-quickstart on Wed May 13 14:22:19 2015.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

.. include:: ../README.rst

Module interface
----------------

.. toctree::
   :maxdepth: 2

.. automodule:: ev3dev

.. autosummary::
    :nosignatures:

    device
    motor
    dc_motor
    servo_motor
    medium_motor
    large_motor
    steering
    sensor
    i2c_sensor
    touch_sensor
    color_sensor
    ultrasonic_sensor
    gyro_sensor
    sound_sensor
    light_sensor
    infrared_sensor
    remote_control
    led
    power_supply
    button
    sound
    lcd
    LCD

Generic device
^^^^^^^^^^^^^^

.. autoclass:: device
    :members:

Motors
^^^^^^

.. autoclass:: motor
    :members:

.. autoclass:: medium_motor
    :members:
    :show-inheritance:

.. autoclass:: large_motor
    :members:
    :show-inheritance:

.. autoclass:: dc_motor
    :members:

.. autoclass:: servo_motor
    :members:

.. autofunction:: steering

Sensors
^^^^^^^

.. autoclass:: sensor
    :members:

.. autoclass:: i2c_sensor
    :members:
    :show-inheritance:

.. autoclass:: touch_sensor
    :members:
    :show-inheritance:

.. autoclass:: color_sensor
    :members:
    :show-inheritance:

.. autoclass:: ultrasonic_sensor
    :members:
    :show-inheritance:

.. autoclass:: gyro_sensor
    :members:
    :show-inheritance:

.. autoclass:: sound_sensor
    :members:
    :show-inheritance:

.. autoclass:: light_sensor
    :members:
    :show-inheritance:

.. autoclass:: infrared_sensor
    :members:
    :show-inheritance:

.. autoclass:: remote_control
    :members:

Other
^^^^^

.. autoclass:: led
    :members:

.. autoclass:: power_supply
    :members:

.. autoclass:: button
    :members:

.. autoclass:: sound
    :members:

.. autoclass:: lcd
    :members:

.. autoclass:: LCD
    :members:
    :show-inheritance:

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

