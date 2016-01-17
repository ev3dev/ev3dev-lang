Special sensor classes
----------------------

The classes derive from :py:class:`Sensor` and provide helper functions
specific to the corresponding sensor type. Each of the functions makes
sure the sensor is in the required mode and then returns the specified value.

.. ~autogen special-sensor-classes

Touch Sensor
########################

.. py:class:: Touch_Sensor

    Touch Sensor


    .. rubric:: inherits from: :py:class:`sensor`


    .. rubric:: Target driver(s): ``lego-ev3-touch, lego-nxt-touch``

    .. rubric:: Special properties

    .. py:attribute:: Is_Pressed

        :class:`boolean, read`


        A boolean indicating whether the current touch sensor is being
        pressed.

        .. rubric:: Required mode: ``TOUCH``
        .. rubric:: Value index: ``0``




Color Sensor
########################

.. py:class:: Color_Sensor

    LEGO EV3 color sensor.


    .. rubric:: inherits from: :py:class:`sensor`


    .. rubric:: Target driver(s): ``lego-ev3-color``
    .. rubric:: ev3dev docs link: http://www.ev3dev.org/docs/sensors/lego-ev3-color-sensor/

    .. rubric:: Special properties

    .. py:attribute:: Reflected_Light_Intensity

        :class:`int, read`


        Reflected light intensity as a percentage. Light on sensor is red.

        .. rubric:: Required mode: ``COL-REFLECT``
        .. rubric:: Value index: ``0``


    .. py:attribute:: Ambient_Light_Intensity

        :class:`int, read`


        Ambient light intensity. Light on sensor is dimly lit blue.

        .. rubric:: Required mode: ``COL-AMBIENT``
        .. rubric:: Value index: ``0``


    .. py:attribute:: Color

        :class:`int, read`


        Color detected by the sensor, categorized by overall value.
          - 0: No color
          - 1: Black
          - 2: Blue
          - 3: Green
          - 4: Yellow
          - 5: Red
          - 6: White
          - 7: Brown

        .. rubric:: Required mode: ``COL-COLOR``
        .. rubric:: Value index: ``0``


    .. py:attribute:: Red

        :class:`int, read`


        Red component of the detected color, in the range 0-1020.

        .. rubric:: Required mode: ``RGB-RAW``
        .. rubric:: Value index: ``0``


    .. py:attribute:: Green

        :class:`int, read`


        Green component of the detected color, in the range 0-1020.

        .. rubric:: Required mode: ``RGB-RAW``
        .. rubric:: Value index: ``1``


    .. py:attribute:: Blue

        :class:`int, read`


        Blue component of the detected color, in the range 0-1020.

        .. rubric:: Required mode: ``RGB-RAW``
        .. rubric:: Value index: ``2``




Ultrasonic Sensor
########################

.. py:class:: Ultrasonic_Sensor

    LEGO EV3 ultrasonic sensor.


    .. rubric:: inherits from: :py:class:`sensor`


    .. rubric:: Target driver(s): ``lego-ev3-us, lego-nxt-us``
    .. rubric:: ev3dev docs link: http://www.ev3dev.org/docs/sensors/lego-ev3-ultrasonic-sensor/

    .. rubric:: Special properties

    .. py:attribute:: Distance_Centimeters

        :class:`float, read`


        Measurement of the distance detected by the sensor,
        in centimeters.

        .. rubric:: Required mode: ``US-DIST-CM``
        .. rubric:: Value index: ``0``


    .. py:attribute:: Distance_Inches

        :class:`float, read`


        Measurement of the distance detected by the sensor,
        in inches.

        .. rubric:: Required mode: ``US-DIST-IN``
        .. rubric:: Value index: ``0``


    .. py:attribute:: Other_Sensor_Present

        :class:`boolean, read`


        Value indicating whether another ultrasonic sensor could
        be heard nearby.

        .. rubric:: Required mode: ``US-LISTEN``
        .. rubric:: Value index: ``0``




Gyro Sensor
########################

.. py:class:: Gyro_Sensor

    LEGO EV3 gyro sensor.


    .. rubric:: inherits from: :py:class:`sensor`


    .. rubric:: Target driver(s): ``lego-ev3-gyro``
    .. rubric:: ev3dev docs link: http://www.ev3dev.org/docs/sensors/lego-ev3-gyro-sensor/

    .. rubric:: Special properties

    .. py:attribute:: Angle

        :class:`int, read`


        The number of degrees that the sensor has been rotated
        since it was put into this mode.

        .. rubric:: Required mode: ``GYRO-ANG``
        .. rubric:: Value index: ``0``


    .. py:attribute:: Rate

        :class:`int, read`


        The rate at which the sensor is rotating, in degrees/second.

        .. rubric:: Required mode: ``GYRO-RATE``
        .. rubric:: Value index: ``0``




Infrared Sensor
########################

.. py:class:: Infrared_Sensor

    LEGO EV3 infrared sensor.


    .. rubric:: inherits from: :py:class:`sensor`


    .. rubric:: Target driver(s): ``lego-ev3-ir``
    .. rubric:: ev3dev docs link: http://www.ev3dev.org/docs/sensors/lego-ev3-infrared-sensor/

    .. rubric:: Special properties

    .. py:attribute:: Proximity

        :class:`int, read`


        A measurement of the distance between the sensor and the remote,
        as a percentage. 100% is approximately 70cm/27in.

        .. rubric:: Required mode: ``IR-PROX``
        .. rubric:: Value index: ``0``




Sound Sensor
########################

.. py:class:: Sound_Sensor

    LEGO NXT Sound Sensor


    .. rubric:: inherits from: :py:class:`sensor`


    .. rubric:: Target driver(s): ``lego-nxt-sound``
    .. rubric:: ev3dev docs link: http://www.ev3dev.org/docs/sensors/lego-nxt-sound-sensor/

    .. rubric:: Special properties

    .. py:attribute:: Sound_Pressure

        :class:`float, read`


        A measurement of the measured sound pressure level, as a
        percent. Uses a flat weighting.

        .. rubric:: Required mode: ``DB``
        .. rubric:: Value index: ``0``


    .. py:attribute:: Sound_Pressure_Low

        :class:`float, read`


        A measurement of the measured sound pressure level, as a
        percent. Uses A-weighting, which focuses on levels up to 55 dB.

        .. rubric:: Required mode: ``DBA``
        .. rubric:: Value index: ``0``




Light Sensor
########################

.. py:class:: Light_Sensor

    LEGO NXT Light Sensor


    .. rubric:: inherits from: :py:class:`sensor`


    .. rubric:: Target driver(s): ``lego-nxt-light``
    .. rubric:: ev3dev docs link: http://www.ev3dev.org/docs/sensors/lego-nxt-light-sensor/

    .. rubric:: Special properties

    .. py:attribute:: Reflected_Light_Intensity

        :class:`float, read`


        A measurement of the reflected light intensity, as a percentage.

        .. rubric:: Required mode: ``REFLECT``
        .. rubric:: Value index: ``0``


    .. py:attribute:: Ambient_Light_Intensity

        :class:`float, read`


        A measurement of the ambient light intensity, as a percentage.

        .. rubric:: Required mode: ``AMBIENT``
        .. rubric:: Value index: ``0``





.. ~autogen
