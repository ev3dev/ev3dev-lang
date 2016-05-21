Classes
-------

Device (abstract)
####################

.. py:class:: Device

    This is the base class that handles control tasks for a single port or
    index. The class must chose one device out of the available ports to
    control. Given an IO port (in the constructor), an implementation should:

    - If the specified port is blank or unspecified/undefined/null, the
      available devices should be enumerated until a suitable device is found.
      Any device is suitable when it's type is known to be compatible with the
      controlling class, and it meets any other requirements specified by the
      caller.
    - If the specified port name is not blank, the available devices should be
      enumerated until a device is found that is plugged in to the specified
      port. The supplied port name should be compared directly to the value
      from the file, so that advanced port strings will match, such as
      ``in1:mux3``.

    If an error occurs after the initial connection, an exception should be
    thrown by the binding informing the caller of what went wrong. Unless the
    error is fatal to the application, no other actions should be taken.

    .. py:attribute:: connected

        If a valid device is found while enumerating the ports, the
        ``connected`` variable is set to ``true`` (by default, it should be
        false). If ``connected`` is false when an attempt is made to read from
        or write to a property file, an error should be thrown (except while in
        the consructor).

.. ~autogen main-spec-classes

Motor
########################

.. py:class:: Motor

    The motor class provides a uniform interface for using motors with
    positional and directional feedback such as the EV3 and NXT motors.
    This feedback allows for precise control of the motors. This is the
    most common type of motor, so we just call it `motor`.
    
    The way to configure a motor is to set the '_sp' attributes when
    calling a command or before. Only in 'run_direct' mode attribute
    changes are processed immediately, in the other modes they only
    take place when a new command is issued.



    .. rubric:: ev3dev docs link: http://www.ev3dev.org/docs/drivers/tacho-motor-class/

    .. rubric:: System properties

    .. py:attribute:: Address

        :class:`string, read`


        Returns the name of the port that this motor is connected to.

    .. py:attribute:: Command

        :class:`string, write`


        Sends a command to the motor controller. See `commands` for a list of
        possible values.

    .. py:attribute:: Commands

        :class:`string array, read`


        Returns a list of commands that are supported by the motor
        controller. Possible values are `run-forever`, `run-to-abs-pos`, `run-to-rel-pos`,
        `run-timed`, `run-direct`, `stop` and `reset`. Not all commands may be supported.
        
        - `run-forever` will cause the motor to run until another command is sent.
        - `run-to-abs-pos` will run to an absolute position specified by `position_sp`
          and then stop using the action specified in `stop_action`.
        - `run-to-rel-pos` will run to a position relative to the current `position` value.
          The new position will be current `position` + `position_sp`. When the new
          position is reached, the motor will stop using the action specified by `stop_action`.
        - `run-timed` will run the motor for the amount of time specified in `time_sp`
          and then stop the motor using the action specified by `stop_action`.
        - `run-direct` will run the motor at the duty cycle specified by `duty_cycle_sp`.
          Unlike other run commands, changing `duty_cycle_sp` while running *will*
          take effect immediately.
        - `stop` will stop any of the run commands before they are complete using the
          action specified by `stop_action`.
        - `reset` will reset all of the motor parameter attributes to their default value.
          This will also have the effect of stopping the motor.

    .. py:attribute:: Count_Per_Rot

        :class:`int, read`


        Returns the number of tacho counts in one rotation of the motor. Tacho counts
        are used by the position and speed attributes, so you can use this value
        to convert rotations or degrees to tacho counts. (rotation motors only)

    .. py:attribute:: Count_Per_M

        :class:`int, read`


        Returns the number of tacho counts in one meter of travel of the motor. Tacho
        counts are used by the position and speed attributes, so you can use this
        value to convert from distance to tacho counts. (linear motors only)

    .. py:attribute:: Driver_Name

        :class:`string, read`


        Returns the name of the driver that provides this tacho motor device.

    .. py:attribute:: Duty_Cycle

        :class:`int, read`


        Returns the current duty cycle of the motor. Units are percent. Values
        are -100 to 100.

    .. py:attribute:: Duty_Cycle_SP

        :class:`int, read/write`


        Writing sets the duty cycle setpoint. Reading returns the current value.
        Units are in percent. Valid values are -100 to 100. A negative value causes
        the motor to rotate in reverse.

    .. py:attribute:: Full_Travel_Count

        :class:`int, read`


        Returns the number of tacho counts in the full travel of the motor. When
        combined with the `count_per_m` atribute, you can use this value to
        calculate the maximum travel distance of the motor. (linear motors only)

    .. py:attribute:: Polarity

        :class:`string, read/write`


        Sets the polarity of the motor. With `normal` polarity, a positive duty
        cycle will cause the motor to rotate clockwise. With `inversed` polarity,
        a positive duty cycle will cause the motor to rotate counter-clockwise.
        Valid values are `normal` and `inversed`.

    .. py:attribute:: Position

        :class:`int, read/write`


        Returns the current position of the motor in pulses of the rotary
        encoder. When the motor rotates clockwise, the position will increase.
        Likewise, rotating counter-clockwise causes the position to decrease.
        Writing will set the position to that value.

    .. py:attribute:: Position_P

        :class:`int, read/write`


        The proportional constant for the position PID.

    .. py:attribute:: Position_I

        :class:`int, read/write`


        The integral constant for the position PID.

    .. py:attribute:: Position_D

        :class:`int, read/write`


        The derivative constant for the position PID.

    .. py:attribute:: Position_SP

        :class:`int, read/write`


        Writing specifies the target position for the `run-to-abs-pos` and `run-to-rel-pos`
        commands. Reading returns the current value. Units are in tacho counts. You
        can use the value returned by `counts_per_rot` to convert tacho counts to/from
        rotations or degrees.

    .. py:attribute:: Max_Speed

        :class:`int, read`


        Returns the maximum value that is accepted by the `speed_sp` attribute. This
        may be slightly different than the maximum speed that a particular motor can
        reach - it's the maximum theoretical speed.

    .. py:attribute:: Speed

        :class:`int, read`


        Returns the current motor speed in tacho counts per second. Note, this is
        not necessarily degrees (although it is for LEGO motors). Use the `count_per_rot`
        attribute to convert this value to RPM or deg/sec.

    .. py:attribute:: Speed_SP

        :class:`int, read/write`


        Writing sets the target speed in tacho counts per second used for all `run-*`
        commands except `run-direct`. Reading returns the current value. A negative
        value causes the motor to rotate in reverse with the exception of `run-to-*-pos`
        commands where the sign is ignored. Use the `count_per_rot` attribute to convert
        RPM or deg/sec to tacho counts per second. Use the `count_per_m` attribute to
        convert m/s to tacho counts per second.

    .. py:attribute:: Ramp_Up_SP

        :class:`int, read/write`


        Writing sets the ramp up setpoint. Reading returns the current value. Units
        are in milliseconds and must be positive. When set to a non-zero value, the
        motor speed will increase from 0 to 100% of `max_speed` over the span of this
        setpoint. The actual ramp time is the ratio of the difference between the
        `speed_sp` and the current `speed` and max_speed multiplied by `ramp_up_sp`.

    .. py:attribute:: Ramp_Down_SP

        :class:`int, read/write`


        Writing sets the ramp down setpoint. Reading returns the current value. Units
        are in milliseconds and must be positive. When set to a non-zero value, the
        motor speed will decrease from 0 to 100% of `max_speed` over the span of this
        setpoint. The actual ramp time is the ratio of the difference between the
        `speed_sp` and the current `speed` and max_speed multiplied by `ramp_down_sp`.

    .. py:attribute:: Speed_P

        :class:`int, read/write`


        The proportional constant for the speed regulation PID.

    .. py:attribute:: Speed_I

        :class:`int, read/write`


        The integral constant for the speed regulation PID.

    .. py:attribute:: Speed_D

        :class:`int, read/write`


        The derivative constant for the speed regulation PID.

    .. py:attribute:: State

        :class:`string array, read`


        Reading returns a list of state flags. Possible flags are
        `running`, `ramping`, `holding`, `overloaded` and `stalled`.

    .. py:attribute:: Stop_Action

        :class:`string, read/write`


        Reading returns the current stop action. Writing sets the stop action.
        The value determines the motors behavior when `command` is set to `stop`.
        Also, it determines the motors behavior when a run command completes. See
        `stop_actions` for a list of possible values.

    .. py:attribute:: Stop_Actions

        :class:`string array, read`


        Returns a list of stop actions supported by the motor controller.
        Possible values are `coast`, `brake` and `hold`. `coast` means that power will
        be removed from the motor and it will freely coast to a stop. `brake` means
        that power will be removed from the motor and a passive electrical load will
        be placed on the motor. This is usually done by shorting the motor terminals
        together. This load will absorb the energy from the rotation of the motors and
        cause the motor to stop more quickly than coasting. `hold` does not remove
        power from the motor. Instead it actively tries to hold the motor at the current
        position. If an external force tries to turn the motor, the motor will 'push
        back' to maintain its position.

    .. py:attribute:: Time_SP

        :class:`int, read/write`


        Writing specifies the amount of time the motor will run when using the
        `run-timed` command. Reading returns the current value. Units are in
        milliseconds.



Large Motor
########################

.. py:class:: Large_Motor

    EV3 large servo motor


    .. rubric:: inherits from: :py:class:`motor`


    .. rubric:: Target driver(s): ``lego-ev3-l-motor``



Medium Motor
########################

.. py:class:: Medium_Motor

    EV3 medium servo motor


    .. rubric:: inherits from: :py:class:`motor`


    .. rubric:: Target driver(s): ``lego-ev3-m-motor``



NXT Motor
########################

.. py:class:: NXT_Motor

    NXT servo motor


    .. rubric:: inherits from: :py:class:`motor`


    .. rubric:: Target driver(s): ``lego-nxt-motor``



Firgelli L12 50 Motor
########################

.. py:class:: Firgelli_L12_50_Motor

    Firgelli L12 50 linear servo motor


    .. rubric:: inherits from: :py:class:`motor`


    .. rubric:: Target driver(s): ``fi-l12-ev3-50``



Firgelli L12 100 Motor
########################

.. py:class:: Firgelli_L12_100_Motor

    Firgelli L12 100 linear servo motor


    .. rubric:: inherits from: :py:class:`motor`


    .. rubric:: Target driver(s): ``fi-l12-ev3-100``



DC Motor
########################

.. py:class:: DC_Motor

    The DC motor class provides a uniform interface for using regular DC motors
    with no fancy controls or feedback. This includes LEGO MINDSTORMS RCX motors
    and LEGO Power Functions motors.



    .. rubric:: ev3dev docs link: http://www.ev3dev.org/docs/drivers/dc-motor-class/

    .. rubric:: System properties

    .. py:attribute:: Address

        :class:`string, read`


        Returns the name of the port that this motor is connected to.

    .. py:attribute:: Command

        :class:`string, write`


        Sets the command for the motor. Possible values are `run-forever`, `run-timed` and
        `stop`. Not all commands may be supported, so be sure to check the contents
        of the `commands` attribute.

    .. py:attribute:: Commands

        :class:`string array, read`


        Returns a list of commands supported by the motor
        controller.

    .. py:attribute:: Driver_Name

        :class:`string, read`


        Returns the name of the motor driver that loaded this device. See the list
        of [supported devices] for a list of drivers.

    .. py:attribute:: Duty_Cycle

        :class:`int, read`


        Shows the current duty cycle of the PWM signal sent to the motor. Values
        are -100 to 100 (-100% to 100%).

    .. py:attribute:: Duty_Cycle_SP

        :class:`int, read/write`


        Writing sets the duty cycle setpoint of the PWM signal sent to the motor.
        Valid values are -100 to 100 (-100% to 100%). Reading returns the current
        setpoint.

    .. py:attribute:: Polarity

        :class:`string, read/write`


        Sets the polarity of the motor. Valid values are `normal` and `inversed`.

    .. py:attribute:: Ramp_Down_SP

        :class:`int, read/write`


        Sets the time in milliseconds that it take the motor to ramp down from 100%
        to 0%. Valid values are 0 to 10000 (10 seconds). Default is 0.

    .. py:attribute:: Ramp_Up_SP

        :class:`int, read/write`


        Sets the time in milliseconds that it take the motor to up ramp from 0% to
        100%. Valid values are 0 to 10000 (10 seconds). Default is 0.

    .. py:attribute:: State

        :class:`string array, read`


        Gets a list of flags indicating the motor status. Possible
        flags are `running` and `ramping`. `running` indicates that the motor is
        powered. `ramping` indicates that the motor has not yet reached the
        `duty_cycle_sp`.

    .. py:attribute:: Stop_Action

        :class:`string, write`


        Sets the stop action that will be used when the motor stops. Read
        `stop_actions` to get the list of valid values.

    .. py:attribute:: Stop_Actions

        :class:`string array, read`


        Gets a list of stop actions. Valid values are `coast`
        and `brake`.

    .. py:attribute:: Time_SP

        :class:`int, read/write`


        Writing specifies the amount of time the motor will run when using the
        `run-timed` command. Reading returns the current value. Units are in
        milliseconds.



Servo Motor
########################

.. py:class:: Servo_Motor

    The servo motor class provides a uniform interface for using hobby type
    servo motors.



    .. rubric:: ev3dev docs link: http://www.ev3dev.org/docs/drivers/servo-motor-class/

    .. rubric:: System properties

    .. py:attribute:: Address

        :class:`string, read`


        Returns the name of the port that this motor is connected to.

    .. py:attribute:: Command

        :class:`string, write`


        Sets the command for the servo. Valid values are `run` and `float`. Setting
        to `run` will cause the servo to be driven to the position_sp set in the
        `position_sp` attribute. Setting to `float` will remove power from the motor.

    .. py:attribute:: Driver_Name

        :class:`string, read`


        Returns the name of the motor driver that loaded this device. See the list
        of [supported devices] for a list of drivers.

    .. py:attribute:: Max_Pulse_SP

        :class:`int, read/write`


        Used to set the pulse size in milliseconds for the signal that tells the
        servo to drive to the maximum (clockwise) position_sp. Default value is 2400.
        Valid values are 2300 to 2700. You must write to the position_sp attribute for
        changes to this attribute to take effect.

    .. py:attribute:: Mid_Pulse_SP

        :class:`int, read/write`


        Used to set the pulse size in milliseconds for the signal that tells the
        servo to drive to the mid position_sp. Default value is 1500. Valid
        values are 1300 to 1700. For example, on a 180 degree servo, this would be
        90 degrees. On continuous rotation servo, this is the 'neutral' position_sp
        where the motor does not turn. You must write to the position_sp attribute for
        changes to this attribute to take effect.

    .. py:attribute:: Min_Pulse_SP

        :class:`int, read/write`


        Used to set the pulse size in milliseconds for the signal that tells the
        servo to drive to the miniumum (counter-clockwise) position_sp. Default value
        is 600. Valid values are 300 to 700. You must write to the position_sp
        attribute for changes to this attribute to take effect.

    .. py:attribute:: Polarity

        :class:`string, read/write`


        Sets the polarity of the servo. Valid values are `normal` and `inversed`.
        Setting the value to `inversed` will cause the position_sp value to be
        inversed. i.e `-100` will correspond to `max_pulse_sp`, and `100` will
        correspond to `min_pulse_sp`.

    .. py:attribute:: Position_SP

        :class:`int, read/write`


        Reading returns the current position_sp of the servo. Writing instructs the
        servo to move to the specified position_sp. Units are percent. Valid values
        are -100 to 100 (-100% to 100%) where `-100` corresponds to `min_pulse_sp`,
        `0` corresponds to `mid_pulse_sp` and `100` corresponds to `max_pulse_sp`.

    .. py:attribute:: Rate_SP

        :class:`int, read/write`


        Sets the rate_sp at which the servo travels from 0 to 100.0% (half of the full
        range of the servo). Units are in milliseconds. Example: Setting the rate_sp
        to 1000 means that it will take a 180 degree servo 2 second to move from 0
        to 180 degrees. Note: Some servo controllers may not support this in which
        case reading and writing will fail with `-EOPNOTSUPP`. In continuous rotation
        servos, this value will affect the rate_sp at which the speed ramps up or down.

    .. py:attribute:: State

        :class:`string array, read`


        Returns a list of flags indicating the state of the servo.
        Possible values are:
        * `running`: Indicates that the motor is powered.



LED
########################

.. py:class:: LED

    Any device controlled by the generic LED driver.
    See https://www.kernel.org/doc/Documentation/leds/leds-class.txt
    for more details.




    .. rubric:: System properties

    .. py:attribute:: Max_Brightness

        :class:`int, read`


        Returns the maximum allowable brightness value.

    .. py:attribute:: Brightness

        :class:`int, read/write`


        Sets the brightness level. Possible values are from 0 to `max_brightness`.

    .. py:attribute:: Triggers

        :class:`string array, read`


        Returns a list of available triggers.

    .. py:attribute:: Trigger

        :class:`string selector, read/write`


        Sets the led trigger. A trigger
        is a kernel based source of led events. Triggers can either be simple or
        complex. A simple trigger isn't configurable and is designed to slot into
        existing subsystems with minimal additional code. Examples are the `ide-disk` and
        `nand-disk` triggers.
        
        Complex triggers whilst available to all LEDs have LED specific
        parameters and work on a per LED basis. The `timer` trigger is an example.
        The `timer` trigger will periodically change the LED brightness between
        0 and the current brightness setting. The `on` and `off` time can
        be specified via `delay_{on,off}` attributes in milliseconds.
        You can change the brightness value of a LED independently of the timer
        trigger. However, if you set the brightness value to 0 it will
        also disable the `timer` trigger.

    .. py:attribute:: Delay_On

        :class:`int, read/write`


        The `timer` trigger will periodically change the LED brightness between
        0 and the current brightness setting. The `on` time can
        be specified via `delay_on` attribute in milliseconds.

    .. py:attribute:: Delay_Off

        :class:`int, read/write`


        The `timer` trigger will periodically change the LED brightness between
        0 and the current brightness setting. The `off` time can
        be specified via `delay_off` attribute in milliseconds.



Button
########################

.. py:class:: Button

    Provides a generic button reading mechanism that can be adapted
    to platform specific implementations. Each platform's specific
    button capabilites are enumerated in the 'platforms' section
    of this specification.






Sensor
########################

.. py:class:: Sensor

    The sensor class provides a uniform interface for using most of the
    sensors available for the EV3. The various underlying device drivers will
    create a `lego-sensor` device for interacting with the sensors.
    
    Sensors are primarily controlled by setting the `mode` and monitored by
    reading the `value<N>` attributes. Values can be converted to floating point
    if needed by `value<N>` / 10.0 ^ `decimals`.
    
    Since the name of the `sensor<N>` device node does not correspond to the port
    that a sensor is plugged in to, you must look at the `address` attribute if
    you need to know which port a sensor is plugged in to. However, if you don't
    have more than one sensor of each type, you can just look for a matching
    `driver_name`. Then it will not matter which port a sensor is plugged in to - your
    program will still work.



    .. rubric:: ev3dev docs link: http://www.ev3dev.org/docs/drivers/lego-sensor-class/

    .. rubric:: System properties

    .. py:attribute:: Address

        :class:`string, read`


        Returns the name of the port that the sensor is connected to, e.g. `ev3:in1`.
        I2C sensors also include the I2C address (decimal), e.g. `ev3:in1:i2c8`.

    .. py:attribute:: Command

        :class:`string, write`


        Sends a command to the sensor.

    .. py:attribute:: Commands

        :class:`string array, read`


        Returns a list of the valid commands for the sensor.
        Returns -EOPNOTSUPP if no commands are supported.

    .. py:attribute:: Decimals

        :class:`int, read`


        Returns the number of decimal places for the values in the `value<N>`
        attributes of the current mode.

    .. py:attribute:: Driver_Name

        :class:`string, read`


        Returns the name of the sensor device/driver. See the list of [supported
        sensors] for a complete list of drivers.

    .. py:attribute:: Mode

        :class:`string, read/write`


        Returns the current mode. Writing one of the values returned by `modes`
        sets the sensor to that mode.

    .. py:attribute:: Modes

        :class:`string array, read`


        Returns a list of the valid modes for the sensor.

    .. py:attribute:: Num_Values

        :class:`int, read`


        Returns the number of `value<N>` attributes that will return a valid value
        for the current mode.

    .. py:attribute:: Units

        :class:`string, read`


        Returns the units of the measured value for the current mode. May return
        empty string



I2C Sensor
########################

.. py:class:: I2C_Sensor

    A generic interface to control I2C-type EV3 sensors.


    .. rubric:: inherits from: :py:class:`sensor`


    .. rubric:: Target driver(s): ``nxt-i2c-sensor``

    .. rubric:: System properties

    .. py:attribute:: FW_Version

        :class:`string, read`


        Returns the firmware version of the sensor if available. Currently only
        I2C/NXT sensors support this.

    .. py:attribute:: Poll_MS

        :class:`int, read/write`


        Returns the polling period of the sensor in milliseconds. Writing sets the
        polling period. Setting to 0 disables polling. Minimum value is hard
        coded as 50 msec. Returns -EOPNOTSUPP if changing polling is not supported.
        Currently only I2C/NXT sensors support changing the polling period.



Power Supply
########################

.. py:class:: Power_Supply

    A generic interface to read data from the system's power_supply class.
    Uses the built-in legoev3-battery if none is specified.




    .. rubric:: System properties

    .. py:attribute:: Measured_Current

        :class:`int, read`


        The measured current that the battery is supplying (in microamps)

    .. py:attribute:: Measured_Voltage

        :class:`int, read`


        The measured voltage that the battery is supplying (in microvolts)

    .. py:attribute:: Max_Voltage

        :class:`int, read`



    .. py:attribute:: Min_Voltage

        :class:`int, read`



    .. py:attribute:: Technology

        :class:`string, read`



    .. py:attribute:: Type

        :class:`string, read`





Lego Port
########################

.. py:class:: Lego_Port

    The `lego-port` class provides an interface for working with input and
    output ports that are compatible with LEGO MINDSTORMS RCX/NXT/EV3, LEGO
    WeDo and LEGO Power Functions sensors and motors. Supported devices include
    the LEGO MINDSTORMS EV3 Intelligent Brick, the LEGO WeDo USB hub and
    various sensor multiplexers from 3rd party manufacturers.
    
    Some types of ports may have multiple modes of operation. For example, the
    input ports on the EV3 brick can communicate with sensors using UART, I2C
    or analog validate signals - but not all at the same time. Therefore there
    are multiple modes available to connect to the different types of sensors.
    
    In most cases, ports are able to automatically detect what type of sensor
    or motor is connected. In some cases though, this must be manually specified
    using the `mode` and `set_device` attributes. The `mode` attribute affects
    how the port communicates with the connected device. For example the input
    ports on the EV3 brick can communicate using UART, I2C or analog voltages,
    but not all at the same time, so the mode must be set to the one that is
    appropriate for the connected sensor. The `set_device` attribute is used to
    specify the exact type of sensor that is connected. Note: the mode must be
    correctly set before setting the sensor type.
    
    Ports can be found at `/sys/class/lego-port/port<N>` where `<N>` is
    incremented each time a new port is registered. Note: The number is not
    related to the actual port at all - use the `address` attribute to find
    a specific port.




    .. rubric:: System properties

    .. py:attribute:: Address

        :class:`string, read`


        Returns the name of the port. See individual driver documentation for
        the name that will be returned.

    .. py:attribute:: Driver_Name

        :class:`string, read`


        Returns the name of the driver that loaded this device. You can find the
        complete list of drivers in the [list of port drivers].

    .. py:attribute:: Modes

        :class:`string array, read`


        Returns a list of the available modes of the port.

    .. py:attribute:: Mode

        :class:`string, read/write`


        Reading returns the currently selected mode. Writing sets the mode.
        Generally speaking when the mode changes any sensor or motor devices
        associated with the port will be removed new ones loaded, however this
        this will depend on the individual driver implementing this class.

    .. py:attribute:: Set_Device

        :class:`string, write`


        For modes that support it, writing the name of a driver will cause a new
        device to be registered for that driver and attached to this port. For
        example, since NXT/Analog sensors cannot be auto-detected, you must use
        this attribute to load the correct driver. Returns -EOPNOTSUPP if setting a
        device is not supported.

    .. py:attribute:: Status

        :class:`string, read`


        In most cases, reading status will return the same value as `mode`. In
        cases where there is an `auto` mode additional values may be returned,
        such as `no-device` or `error`. See individual port driver documentation
        for the full list of possible values.




.. ~autogen

