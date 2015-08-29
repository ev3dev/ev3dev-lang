ev3dev Language Wrapper Specification (DRAFT ver `0.9.3`, rev 1)
===
This is an unofficial specification that defines a unified interface for language wrappers to expose the [ev3dev](http://www.ev3dev.org) device APIs.

General Notes
---
Because this specification is meant to be implemented in multiple languages, the specific naming conventions of properties, methods and classes are not defined here. Depending on the language, names will be slightly different (ex. "touchSensor" or "TouchSensor" or "touch-sensor") so that they fit the language's naming conventions.

Some concepts that apply to multiple classes are described as "abstracts". These abstract sections explain how the class should handle specific situations, and do not necessarily translate in to their own class in the wrapper.

<!-- ~autogen autogen-header 'xml'>commentStyle -->
<!-- Sections of the following code were auto-generated based on spec v0.9.3-pre, rev 1. -->
<!-- ~autogen -->

Implementation Notes (important)
---
- File access. There should be one class that is used or inherited from in all other classes that need to access object properties via file I/O. This class should check paths for validity, do basic error checking, and generally implement as much of the core I/O functionality as possible.
- Errors. All file access and other error-prone calls should be wrapped with error handling. If an error thrown by an external call is fatal, the wrapper should throw an error for the caller that states the error and gives some insight in to what actually happened.
- Naming conventions. All names should follow the language's naming conventions. Keep the names consistent, so that users can easily find what they want.
- Attribute types. `int` and `string` attributes are read-write files
  containing a single value that is representable either as an integer or as a
  single word. A `string array` attribute is a readonly file that contains
  space-separated list of words, where each word is a possible value of some
  other `string` atribute.  And a `string selector` attribute is a read-write
  file that contains space-separated list of possible values, where the
  currently selected value is enclosed in square brackets. Another value may be
  selected by writing a single word to the file.

<hr/>

`Motor` (class) : abstract "IO Device"
-----

<!-- ~autogen md_generic-class-description classes.motor>currentClass -->

The motor class provides a uniform interface for using motors with
positional and directional feedback such as the EV3 and NXT motors.
This feedback allows for precise control of the motors. This is the
most common type of motor, so we just call it `motor`.

<!-- ~autogen -->

###Constructor:

Argument Name|Type|Description
---|---|---
Port|String|The port to control. Specify a blank string (or the undefined/null value for the language) for an automatic search. It is recommended to use the `OUTPUT_*` constants.
Driver Name|String|The motor driver that should be driving the target motor (generally specifies the type of motor). Can be left empty or undefined (in the languages that support it) to specify a wildcard.

###Direct attribute mappings:

<!-- ~autogen md_generic-property-table classes.motor>currentClass -->

Property Name|Type|Accessibility|Description
---|---|---|---
Command|string|Write| Sends a command to the motor controller. See `commands` for a list of possible values.
Commands|string array|Read| Returns a list of commands that are supported by the motor controller. Possible values are `run-forever`, `run-to-abs-pos`, `run-to-rel-pos`, `run-timed`, `run-direct`, `stop` and `reset`. Not all commands may be supported. `run-forever` will cause the motor to run until another command is sent. `run-to-abs-pos` will run to an absolute position specified by `position_sp` and then stop using the command specified in `stop_command`. `run-to-rel-pos` will run to a position relative to the current `position` value. The new position will be current `position` + `position_sp`. When the new position is reached, the motor will stop using the command specified by `stop_command`. `run-timed` will run the motor for the amount of time specified in `time_sp` and then stop the motor using the command specified by `stop_command`. `run-direct` will run the motor at the duty cycle specified by `duty_cycle_sp`. Unlike other run commands, changing `duty_cycle_sp` while running *will* take effect immediately. `stop` will stop any of the run commands before they are complete using the command specified by `stop_command`. `reset` will reset all of the motor parameter attributes to their default value. This will also have the effect of stopping the motor.
Count Per Rot|int|Read| Returns the number of tacho counts in one rotation of the motor. Tacho counts are used by the position and speed attributes, so you can use this value to convert rotations or degrees to tacho counts. In the case of linear actuators, the units here will be counts per centimeter.
Driver Name|string|Read| Returns the name of the driver that provides this tacho motor device.
Duty Cycle|int|Read| Returns the current duty cycle of the motor. Units are percent. Values are -100 to 100.
Duty Cycle SP|int|Read/Write| Writing sets the duty cycle setpoint. Reading returns the current value. Units are in percent. Valid values are -100 to 100. A negative value causes the motor to rotate in reverse. This value is only used when `speed_regulation` is off.
Encoder Polarity|string|Read/Write| Sets the polarity of the rotary encoder. This is an advanced feature to all use of motors that send inversed encoder signals to the EV3. This should be set correctly by the driver of a device. It You only need to change this value if you are using a unsupported device. Valid values are `normal` and `inversed`.
Polarity|string|Read/Write| Sets the polarity of the motor. With `normal` polarity, a positive duty cycle will cause the motor to rotate clockwise. With `inversed` polarity, a positive duty cycle will cause the motor to rotate counter-clockwise. Valid values are `normal` and `inversed`.
Port Name|string|Read| Returns the name of the port that the motor is connected to.
Position|int|Read/Write| Returns the current position of the motor in pulses of the rotary encoder. When the motor rotates clockwise, the position will increase. Likewise, rotating counter-clockwise causes the position to decrease. Writing will set the position to that value.
Position P|int|Read/Write| The proportional constant for the position PID.
Position I|int|Read/Write| The integral constant for the position PID.
Position D|int|Read/Write| The derivative constant for the position PID.
Position SP|int|Read/Write| Writing specifies the target position for the `run-to-abs-pos` and `run-to-rel-pos` commands. Reading returns the current value. Units are in tacho counts. You can use the value returned by `counts_per_rot` to convert tacho counts to/from rotations or degrees.
Speed|int|Read| Returns the current motor speed in tacho counts per second. Not, this is not necessarily degrees (although it is for LEGO motors). Use the `count_per_rot` attribute to convert this value to RPM or deg/sec.
Speed SP|int|Read/Write| Writing sets the target speed in tacho counts per second used when `speed_regulation` is on. Reading returns the current value.  Use the `count_per_rot` attribute to convert RPM or deg/sec to tacho counts per second.
Ramp Up SP|int|Read/Write| Writing sets the ramp up setpoint. Reading returns the current value. Units are in milliseconds. When set to a value > 0, the motor will ramp the power sent to the motor from 0 to 100% duty cycle over the span of this setpoint when starting the motor. If the maximum duty cycle is limited by `duty_cycle_sp` or speed regulation, the actual ramp time duration will be less than the setpoint.
Ramp Down SP|int|Read/Write| Writing sets the ramp down setpoint. Reading returns the current value. Units are in milliseconds. When set to a value > 0, the motor will ramp the power sent to the motor from 100% duty cycle down to 0 over the span of this setpoint when stopping the motor. If the starting duty cycle is less than 100%, the ramp time duration will be less than the full span of the setpoint.
Speed Regulation Enabled|string|Read/Write| Turns speed regulation on or off. If speed regulation is on, the motor controller will vary the power supplied to the motor to try to maintain the speed specified in `speed_sp`. If speed regulation is off, the controller will use the power specified in `duty_cycle_sp`. Valid values are `on` and `off`.
Speed Regulation P|int|Read/Write| The proportional constant for the speed regulation PID.
Speed Regulation I|int|Read/Write| The integral constant for the speed regulation PID.
Speed Regulation D|int|Read/Write| The derivative constant for the speed regulation PID.
State|string array|Read| Reading returns a list of state flags. Possible flags are `running`, `ramping` `holding` and `stalled`.
Stop Command|string|Read/Write| Reading returns the current stop command. Writing sets the stop command. The value determines the motors behavior when `command` is set to `stop`. Also, it determines the motors behavior when a run command completes. See `stop_commands` for a list of possible values.
Stop Commands|string array|Read| Returns a list of stop modes supported by the motor controller. Possible values are `coast`, `brake` and `hold`. `coast` means that power will be removed from the motor and it will freely coast to a stop. `brake` means that power will be removed from the motor and a passive electrical load will be placed on the motor. This is usually done by shorting the motor terminals together. This load will absorb the energy from the rotation of the motors and cause the motor to stop more quickly than coasting. `hold` does not remove power from the motor. Instead it actively try to hold the motor at the current position. If an external force tries to turn the motor, the motor will 'push back' to maintain its position.
Time SP|int|Read/Write| Writing specifies the amount of time the motor will run when using the `run-timed` command. Reading returns the current value. Units are in milliseconds.


<!-- ~autogen -->

###Special properties:

Property Name|Type|Accessibility|Description
---|---|---|---
Device Index|Number|Read
Connected|Boolean|Read

###Methods:

Method Name|Return Type|Arguments|Description
---|---|---|---
Reset|Void|None|Sets the `command` motor property to `reset`, which causes the motor driver to reset all of the motor's parameters and state.

###Helper functions:

Each motor class should have helper functions for each command that the library supports.
These helper functions can accept parameters to set properties before the command is sent,
or can just require that necessary properties are set beforehand.

<hr/>

`DC Motor` (class) : abstract "IO Device"
-----

<!-- ~autogen md_generic-class-description classes.dcMotor>currentClass -->

The DC motor class provides a uniform interface for using regular DC motors
with no fancy controls or feedback. This includes LEGO MINDSTORMS RCX motors
and LEGO Power Functions motors.

<!-- ~autogen -->

###Constructor:

Argument Name|Type|Description
---|---|---
Port|String|The port to control. Specify a blank string (or the undefined/null value for the language) for an automatic search. It is recommended to use the `OUTPUT_*` constants.

###Direct attribute mappings:

<!-- ~autogen md_generic-property-table classes.dcMotor>currentClass -->

Property Name|Type|Accessibility|Description
---|---|---|---
Command|string|Write| Sets the command for the motor. Possible values are `run-forever`, `run-timed` and `stop`. Not all commands may be supported, so be sure to check the contents of the `commands` attribute.
Commands|string array|Read| Returns a list of commands supported by the motor controller.
Driver Name|string|Read| Returns the name of the motor driver that loaded this device. See the list of [supported devices] for a list of drivers.
Duty Cycle|int|Read| Shows the current duty cycle of the PWM signal sent to the motor. Values are -100 to 100 (-100% to 100%).
Duty Cycle SP|int|Read/Write| Writing sets the duty cycle setpoint of the PWM signal sent to the motor. Valid values are -100 to 100 (-100% to 100%). Reading returns the current setpoint.
Polarity|string|Read/Write| Sets the polarity of the motor. Valid values are `normal` and `inversed`.
Port Name|string|Read| Returns the name of the port that the motor is connected to.
Ramp Down SP|int|Read/Write| Sets the time in milliseconds that it take the motor to ramp down from 100% to 0%. Valid values are 0 to 10000 (10 seconds). Default is 0.
Ramp Up SP|int|Read/Write| Sets the time in milliseconds that it take the motor to up ramp from 0% to 100%. Valid values are 0 to 10000 (10 seconds). Default is 0.
State|string array|Read| Gets a list of flags indicating the motor status. Possible flags are `running` and `ramping`. `running` indicates that the motor is powered. `ramping` indicates that the motor has not yet reached the `duty_cycle_sp`.
Stop Command|string|Write| Sets the stop command that will be used when the motor stops. Read `stop_commands` to get the list of valid values.
Stop Commands|string array|Read| Gets a list of stop commands. Valid values are `coast` and `brake`.


<!-- ~autogen -->

###Special properties:

Property Name|Type|Accessibility|Description
---|---|---|---
Device Index|Number|Read
Connected|Boolean|Read

<hr/>

`Servo Motor` (class) : abstract "IO Device"
-----

<!-- ~autogen md_generic-class-description classes.servoMotor>currentClass -->

The servo motor class provides a uniform interface for using hobby type
servo motors.

<!-- ~autogen -->

###Constructor:

Argument Name|Type|Description
---|---|---
Port|String|The port to control. Specify a blank string (or the undefined/null value for the language) for an automatic search. It is recommended to use the `OUTPUT_*` constants.

###Direct attribute mappings:

<!-- ~autogen md_generic-property-table classes.servoMotor>currentClass -->

Property Name|Type|Accessibility|Description
---|---|---|---
Command|string|Write| Sets the command for the servo. Valid values are `run` and `float`. Setting to `run` will cause the servo to be driven to the position_sp set in the `position_sp` attribute. Setting to `float` will remove power from the motor.
Driver Name|string|Read| Returns the name of the motor driver that loaded this device. See the list of [supported devices] for a list of drivers.
Max Pulse SP|int|Read/Write| Used to set the pulse size in milliseconds for the signal that tells the servo to drive to the maximum (clockwise) position_sp. Default value is 2400. Valid values are 2300 to 2700. You must write to the position_sp attribute for changes to this attribute to take effect.
Mid Pulse SP|int|Read/Write| Used to set the pulse size in milliseconds for the signal that tells the servo to drive to the mid position_sp. Default value is 1500. Valid values are 1300 to 1700. For example, on a 180 degree servo, this would be 90 degrees. On continuous rotation servo, this is the 'neutral' position_sp where the motor does not turn. You must write to the position_sp attribute for changes to this attribute to take effect.
Min Pulse SP|int|Read/Write| Used to set the pulse size in milliseconds for the signal that tells the servo to drive to the miniumum (counter-clockwise) position_sp. Default value is 600. Valid values are 300 to 700. You must write to the position_sp attribute for changes to this attribute to take effect.
Polarity|string|Read/Write| Sets the polarity of the servo. Valid values are `normal` and `inversed`. Setting the value to `inversed` will cause the position_sp value to be inversed. i.e `-100` will correspond to `max_pulse_sp`, and `100` will correspond to `min_pulse_sp`.
Port Name|string|Read| Returns the name of the port that the motor is connected to.
Position SP|int|Read/Write| Reading returns the current position_sp of the servo. Writing instructs the servo to move to the specified position_sp. Units are percent. Valid values are -100 to 100 (-100% to 100%) where `-100` corresponds to `min_pulse_sp`, `0` corresponds to `mid_pulse_sp` and `100` corresponds to `max_pulse_sp`.
Rate SP|int|Read/Write| Sets the rate_sp at which the servo travels from 0 to 100.0% (half of the full range of the servo). Units are in milliseconds. Example: Setting the rate_sp to 1000 means that it will take a 180 degree servo 2 second to move from 0 to 180 degrees. Note: Some servo controllers may not support this in which case reading and writing will fail with `-EOPNOTSUPP`. In continuous rotation servos, this value will affect the rate_sp at which the speed ramps up or down.
State|string array|Read| Returns a list of flags indicating the state of the servo. Possible values are: * `running`: Indicates that the motor is powered.


<!-- ~autogen -->

###Special properties:

Property Name|Type|Accessibility|Description
---|---|---|---
Device Index|Number|Read
Connected|Boolean|Read

<hr/>

`Sensor` (class) : abstract "IO Device"
-----
###Constructor:

Argument Name|Type|Description
---|---|---
Port|String|The port to control. Specify a blank string (or the undefined/null value for the language) for an automatic search. It is recommended to use the `INPUT_*` constants.
Types|String Array|The types of sensors (device IDs) to allow. Leave the array empty or undefined (in the languages that support it) to specify a wildcard.

###Direct attribute mappings:

<!-- ~autogen md_generic-property-table classes.sensor>currentClass -->

Property Name|Type|Accessibility|Description
---|---|---|---
Command|string|Write| Sends a command to the sensor.
Commands|string array|Read| Returns a list of the valid commands for the sensor. Returns -EOPNOTSUPP if no commands are supported.
Decimals|int|Read| Returns the number of decimal places for the values in the `value<N>` attributes of the current mode.
Driver Name|string|Read| Returns the name of the sensor device/driver. See the list of [supported sensors] for a complete list of drivers.
Mode|string|Read/Write| Returns the current mode. Writing one of the values returned by `modes` sets the sensor to that mode.
Modes|string array|Read| Returns a list of the valid modes for the sensor.
Num Values|int|Read| Returns the number of `value<N>` attributes that will return a valid value for the current mode.
Port Name|string|Read| Returns the name of the port that the sensor is connected to, e.g. `ev3:in1`. I2C sensors also include the I2C address (decimal), e.g. `ev3:in1:i2c8`.
Units|string|Read| Returns the units of the measured value for the current mode. May return empty string


<!-- ~autogen -->

###Special properties:

Property Name|Type|Accessibility|Description
---|---|---|---
Device Index|Number|Read
Connected|Boolean|Read

###Methods:

Method Name|Return Type|Arguments|Description
---|---|---|---
Get Value|Number (int)|Value Index : Number|Gets the raw value at the specified index
Get Float Value|Number (float)|Value Index : Number|Gets the value at the specified index, adjusted for the sensor's `dp` value

<hr/>

`I2C Sensor` (class) : extends `Sensor`
-----

<!-- ~autogen md_generic-class-description classes.i2cSensor>currentClass -->

A generic interface to control I2C-type EV3 sensors.

<!-- ~autogen -->

###Constructor:
The constructor for the `I2C Sensor` class is the same as its parent's constructor
(the `Sensor` class).

###Direct attribute mappings:

<!-- ~autogen md_generic-property-table classes.i2cSensor>currentClass -->

Property Name|Type|Accessibility|Description
---|---|---|---
FW Version|string|Read| Returns the firmware version of the sensor if available. Currently only I2C/NXT sensors support this.
Poll MS|int|Read/Write| Returns the polling period of the sensor in milliseconds. Writing sets the polling period. Setting to 0 disables polling. Minimum value is hard coded as 50 msec. Returns -EOPNOTSUPP if changing polling is not supported. Currently only I2C/NXT sensors support changing the polling period.


<!-- ~autogen -->

<hr/>

`Power Supply` (class)
-----

<!-- ~autogen md_generic-class-description classes.powerSupply>currentClass -->

A generic interface to read data from the system's power_supply class.
Uses the built-in legoev3-battery if none is specified.

<!-- ~autogen -->

###Constructor:

Argument Name|Type|Description
---|---|---
Device (optional)|String|The name of the device to control (as listed in `/sys/class/power_supply/`). If left blank or unspecified, the default `legoev3-battery` should be used. `Connected` should be set to true if the device is found.

###Direct attribute mappings:

<!-- ~autogen md_generic-property-table classes.powerSupply>currentClass -->

Property Name|Type|Accessibility|Description
---|---|---|---
Measured Current|int|Read| The measured current that the battery is supplying (in microamps)
Measured Voltage|int|Read| The measured voltage that the battery is supplying (in microvolts)
Max Voltage|int|Read|
Min Voltage|int|Read|
Technology|string|Read|
Type|string|Read|


<!-- ~autogen -->

###Special properties:

Property Name|Type|Accessibility|Description
---|---|---|---
Current Amps|Number (float)|Read|The amount of current, in amps, coming from the device (`current_now` / 1000000)
Voltage Volts|Number (float)|Read|The number of volts (not µV) coming from the device (`voltage_now` / 1000000)
Connected|Boolean|Read

**NOTE:** The integer measures for current and voltage are in µA and µV, respectively, as returned from the sysfs attribute.

<hr/>

`LED` (class)
-----

<!-- ~autogen md_generic-class-description classes.led>currentClass -->

Any device controlled by the generic LED driver.
See https://www.kernel.org/doc/Documentation/leds/leds-class.txt
for more details.

<!-- ~autogen -->

###Constructor:

Argument Name|Type|Description
---|---|---
Device|String|The name of the device to control (as listed in `/sys/class/leds/`). `Connected` should be set to true if the device is found. If left blank or unspecified, `Connected` shold be set to false.

###Direct attribute mappings:

<!-- ~autogen md_generic-property-table classes.led>currentClass -->

Property Name|Type|Accessibility|Description
---|---|---|---
Max Brightness|int|Read| Returns the maximum allowable brightness value.
Brightness|int|Read/Write| Sets the brightness level. Possible values are from 0 to `max_brightness`.
Triggers|string array|Read| Returns a list of available triggers.
Trigger|string selector|Read/Write| Sets the led trigger. A trigger is a kernel based source of led events. Triggers can either be simple or complex. A simple trigger isn't configurable and is designed to slot into existing subsystems with minimal additional code. Examples are the `ide-disk` and `nand-disk` triggers.  Complex triggers whilst available to all LEDs have LED specific parameters and work on a per LED basis. The `timer` trigger is an example. The `timer` trigger will periodically change the LED brightness between 0 and the current brightness setting. The `on` and `off` time can be specified via `delay_{on,off}` attributes in milliseconds. You can change the brightness value of a LED independently of the timer trigger. However, if you set the brightness value to 0 it will also disable the `timer` trigger.
Delay On|int|Read/Write| The `timer` trigger will periodically change the LED brightness between 0 and the current brightness setting. The `on` time can be specified via `delay_on` attribute in milliseconds.
Delay Off|int|Read/Write| The `timer` trigger will periodically change the LED brightness between 0 and the current brightness setting. The `off` time can be specified via `delay_off` attribute in milliseconds.


<!-- ~autogen -->

###Special properties:

Property Name|Type|Accessibility|Description
---|---|---|---
Connected|Boolean|Read
Brightness Pct | Number | Read/Write | Gets or sets the LED's brightness as a percentage (0-1) of the maximum.

###Methods

Method name | Return type | Arguments | Description
---|---|---|---
On    | void | None | Turns the led on by setting its brightness to the maximum level.
Off   | void | None | Turns the led off.
Flash | void | ON interval: Number, OFF interval: Number | Enables `timer` trigger and sets `delay_on` and `delay_off` attributes to the provided values (in milliseconds).

###Static methods

<!-- ~autogen md_led-color-methods -->
Method name | Return type | Arguments | Description
---|---|---|---
Set Red | void | Intensity: Number | Sets the brightness of the built-in EV3 LEDs so that they appear red, using the specified intensity percentage (0-1).
Red On | void | None | Sets the brightness of the built-in EV3 LEDs so that they appear red at full intensity.
Set Green | void | Intensity: Number | Sets the brightness of the built-in EV3 LEDs so that they appear green, using the specified intensity percentage (0-1).
Green On | void | None | Sets the brightness of the built-in EV3 LEDs so that they appear green at full intensity.
Set Amber | void | Intensity: Number | Sets the brightness of the built-in EV3 LEDs so that they appear amber, using the specified intensity percentage (0-1).
Amber On | void | None | Sets the brightness of the built-in EV3 LEDs so that they appear amber at full intensity.
Set Orange | void | Intensity: Number | Sets the brightness of the built-in EV3 LEDs so that they appear orange, using the specified intensity percentage (0-1).
Orange On | void | None | Sets the brightness of the built-in EV3 LEDs so that they appear orange at full intensity.
Set Yellow | void | Intensity: Number | Sets the brightness of the built-in EV3 LEDs so that they appear yellow, using the specified intensity percentage (0-1).
Yellow On | void | None | Sets the brightness of the built-in EV3 LEDs so that they appear yellow at full intensity.
Mix Colors| void | Red Percent: Number, Green Percent: Number | Sets the LEDs to the specified percentage (0-1) of their max brightness.
All Off   | void | None | Turns all leds off.
<!-- ~autogen -->

###Predefined instances

There are four predefined instances of the LED class corresponding to the EV3
leds:

* Red Right
* Red Left
* Green Right
* Green Left

<hr/>

`Lego Port` (class) : abstract "IO Device"
-----

<!-- ~autogen md_generic-class-description classes.legoPort>currentClass -->

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
related to the actual port at all - use the `port_name` attribute to find
a specific port.

<!-- ~autogen -->

###Constructor:

Argument Name|Type|Description
---|---|---
Port|String|The port to control. Specify a blank string (or the undefined/null value for the language) for an automatic search. It is recommended to use the `OUTPUT_*` constants.

###Direct attribute mappings:

<!-- ~autogen md_generic-property-table classes.legoPort>currentClass -->

Property Name|Type|Accessibility|Description
---|---|---|---
Driver Name|string|Read| Returns the name of the driver that loaded this device. You can find the complete list of drivers in the [list of port drivers].
Modes|string array|Read| Returns a list of the available modes of the port.
Mode|string|Read/Write| Reading returns the currently selected mode. Writing sets the mode. Generally speaking when the mode changes any sensor or motor devices associated with the port will be removed new ones loaded, however this this will depend on the individual driver implementing this class.
Port Name|string|Read| Returns the name of the port. See individual driver documentation for the name that will be returned.
Set Device|string|Write| For modes that support it, writing the name of a driver will cause a new device to be registered for that driver and attached to this port. For example, since NXT/Analog sensors cannot be auto-detected, you must use this attribute to load the correct driver. Returns -EOPNOTSUPP if setting a device is not supported.
Status|string|Read| In most cases, reading status will return the same value as `mode`. In cases where there is an `auto` mode additional values may be returned, such as `no-device` or `error`. See individual port driver documentation for the full list of possible values.


<!-- ~autogen -->

###Special properties:

Property Name|Type|Accessibility|Description
---|---|---|---
Device Index|Number|Read
Connected|Boolean|Read

<hr/>

Constants / Enums
---

Due to the inherent differences between the various languages that we support here, the enums listed below can also be declared as global constants.

###`Ports`

Name|Value|Description
---|---|---
`INPUT_AUTO`|instance-specific (see below for details)|Automatic input selection
`OUTPUT_AUTO`|instance-specific (see below for details)|Automatic output selection
`INPUT_1`|"in1"|Sensor port 1
`INPUT_2`|"in2"|Sensor port 2
`INPUT_3`|"in3"|Sensor port 3
`INPUT_4`|"in4"|Sensor port 4
`OUTPUT_A`|"outA"|Motor port A
`OUTPUT_B`|"outB"|Motor port B
`OUTPUT_C`|"outC"|Motor port C
`OUTPUT_D`|"outD"|Motor port D

The values for the `*_AUTO` constants can be chosen by the implementation. They can have any value that signifies an auto-search.

<hr/>

IO Device (abstract)
---
An IO Device handles control tasks for a single port or index. These  classes must chose one device out of the available ports to control. Given an IO port (in the constructor), an implementation should:

* If the specified port is blank or unspecified/undefined/null, the available devices should be enumerated until a suitable device is found. Any device is suitable when it's type is known to be compatible with the controlling class, and it meets any other requirements specified by the caller.
* If the specified port name is not blank, the available devices should be enumerated until a device is found that is plugged in to the specified port. The supplied port name should be compared directly to the value from the file, so that advanced port strings will match, such as `in1:mux3`.

All IO devices should have a `connected` variable. If a valid device is found while enumerating the ports, the `connected` variable should be set to `true` (by default, it should be false). If `connected` is false when an attempt is made to read from or write to a property file, an error should be thrown (except while in the consructor).

If an error occurs after the initial connection, an exception should be thrown by the binding informing the caller of what went wrong. Unless the error is fatal to the application, no other actions should be taken.

Compatibility
---
Starting after version `0.9.0`, we will be documenting the versions of ev3dev that the libraries are compatible with.

Compatibility table:

Language Binding Version|Fully Supported Kernel Version
---|---|---
`v0.9.1`|`v3.16.1-7-ev3dev`
`v0.9.2`|`v3.16.7-ckt10-4-ev3dev-ev3`
