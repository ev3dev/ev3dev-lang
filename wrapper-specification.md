ev3dev Language Wrapper Specification (Draft)
===
This is an unofficial specification that defines a unified interface for language wrappers to expose the [ev3dev](http://www.ev3dev.org) device APIs. 

Notes
---
Because this specification is meant to be implimented in multiple languages, the specific naming conventions of properties, methods and classes are not defined here. Depending on the language, names will be slightly different (ex. "touchSensor" or "TouchSensor" or "touch-sensor") so that they fit the language's naming conventions. 


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
