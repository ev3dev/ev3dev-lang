ev3dev Language Wrapper Specification (Draft)
===
This is an unofficial specification that defines a unified interface for language wrappers to expose the [ev3dev](http://www.ev3dev.org) device APIs. 

General Notes
---
Because this specification is meant to be implemented in multiple languages, the specific naming conventions of properties, methods and classes are not defined here. Depending on the language, names will be slightly different (ex. "touchSensor" or "TouchSensor" or "touch-sensor") so that they fit the language's naming conventions. 

Implementation Notes
---
- File access. There should be one class that is used or inherited from in all other classes that need to access object properties via file I/O. This class should check paths for validity, do basic error checking, and generally implement as much of the core I/O functionality as possible.
- Errors. All file access and other error-prone calls should be wrapped with error handling. If an error thrown by an external call is fatal, the wrapper should throw an error for the caller that states the error and gives some insight in to what actually happened.
- Naming conventions. All names should follow the language's naming conventions. Keep the names consistent, so that users can easily find what they want.

`Motor` (class)
-----
Direct attribute mappings:

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

Special properties:

Property Name|Type|Accessibility|Description
---|---|---|---
Device Index|Number|Read


`Sensor` (class)
-----
Direct attribute mappings:

Property Name|Type|Accessibility|Description
---|---|---|---
Port Name|String|Read
Num Values|Number|Read
Type ID|Number|Read
Mode|String|Read/Write
Modes|String Array|Read

Special properties:

Property Name|Type|Accessibility|Description
---|---|---|---
Device Index|Number|Read

Methods:

Method Name|Return Type|Arguments|Description
---|---|---|---
GetValue|Number|ValueIndex : Number|Gets the value at the specified index, adjusted for the sensor's `dp` value