ev3dev Language Wrapper Specification (Draft)
===
This is an unofficial specification that defines a unified interface for language wrappers to expose the [ev3dev](http://www.ev3dev.org) device APIs. 

General Notes
---
Because this specification is meant to be implemented in multiple languages, the specific naming conventions of properties, methods and classes are not defined here. Depending on the language, names will be slightly different (ex. "touchSensor" or "TouchSensor" or "touch-sensor") so that they fit the language's naming conventions.

Some concepts that apply to multiple classes are described as "abstracts". These abstract sections explain how the class should handle specific situations, and do not necessarily translate in to their own class in the wrapper.

Implementation Notes (important)
---
- File access. There should be one class that is used or inherited from in all other classes that need to access object properties via file I/O. This class should check paths for validity, do basic error checking, and generally implement as much of the core I/O functionality as possible.
- Errors. All file access and other error-prone calls should be wrapped with error handling. If an error thrown by an external call is fatal, the wrapper should throw an error for the caller that states the error and gives some insight in to what actually happened.
- Naming conventions. All names should follow the language's naming conventions. Keep the names consistent, so that users can easily find what they want.

`Motor` (class) : abstract "IO Device"
-----
###Constructor:

Argument Name|Type|Description
---|---|---
Port|Number|The port to control. Specify `0` for an automatic search. It is recommended to use the `OUTPUT_*` constants. 

###Direct attribute mappings:

Property Name|Type|Accessibility|Description
---|---|---|---
Duty Cycle|Number|Read
Duty Cycle SP|Number|Read/Write
Port Name|String|Read
Position|Number|Read/Write
Position Mode|String|Read/Write
Position SP|Number|Read/Write
Pulses Per Second|Number|Read
Pulses Per Second SP|Number|Read/Write
Ramp Down SP|Number|Read/Write
Ramp Up SP|Number|Read/Write
Regulation Mode|String|Read/Write
Run|Number|Read/Write
Run Mode|String|Read/Write
Speed Regulation P|Number|Read/Write
Speed Regulation I|Number|Read/Write
Speed Regulation D|Number|Read/Write
Speed Regulation K|Number|Read/Write
State|String|Read
Stop Mode|String|Read/Write
Stop Modes|String Array|Read
Time SP|Number|Read/Write
Type|String|Read

###Special properties:

Property Name|Type|Accessibility|Description
---|---|---|---
Device Index|Number|Read


`Sensor` (class) : abstract "IO Device"
-----
###Constructor:

Argument Name|Type|Description
---|---|---
Port|Number|The port to control. Specify `0` for an automatic search. It is recommended to use the `INPUT_*` constants. 

###Direct attribute mappings:

Property Name|Type|Accessibility|Description
---|---|---|---
Port Name|String|Read
Num Values|Number|Read
Type ID|Number|Read
Mode|String|Read/Write
Modes|String Array|Read

###Special properties:

Property Name|Type|Accessibility|Description
---|---|---|---
Device Index|Number|Read

###Methods:

Method Name|Return Type|Arguments|Description
---|---|---|---
GetRawValue|Number (int)|ValueIndex : Number|Gets the raw value at the specified index
GetValue|Number (float)|ValueIndex : Number|Gets the value at the specified index, adjusted for the sensor's `dp` value

Global Constants
---

Constant Name|Value|Description
---|---|---
INPUT_AUTO|0|Automatic input selection
OUTPUT_AUTO|0|Automatic output selection
INPUT_1|1|Sensor port 1
INPUT_2|2|Sensor port 2
INPUT_3|3|Sensor port 3
INPUT_4|4|Sensor port 4
OUTPUT_A|1|Motor port A
OUTPUT_B|2|Motor port B
OUTPUT_C|3|Motor port C
OUTPUT_D|4|Motor port D

IO Device (abstract)
---
An IO Device handles control tasks for a single port or index. These  classes must chose one device out of the available ports to control. Given an IO port (in the constructor), an implementation should:

- If the specified port is `0` or undefined, the available devices should be enumerated until a suitable device is found. Any device is suitable when it's type is known to be compatible with the controlling class. If no suitable device is found, an error should be thrown.
- If the specified port is non-zero and in the valid port range for that device, the available devices should be enumerated until a device is found that is plugged in to the specified port. If no suitable device is found, an error should be thrown.

