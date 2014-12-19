///<reference path="node.d.ts" />
///<reference path="include.ts" />
///<reference path="io.ts" />
///<reference path="motor.ts" />
///<reference path="sensor.ts" />
///<reference path="extras.ts" />

module.exports.ports = ports;

/* CLASS EXPORTS */
//IO
module.exports.Device = Device;
//Motor
module.exports.Motor = Motor;
module.exports.ServoMotor = ServoMotor;
module.exports.DCMotor = DCMotor;
//Sensor
module.exports.Sensor = Sensor;
module.exports.I2CSensor = I2CSensor;
//Extras
module.exports.PowerSupply = PowerSupply;
module.exports.LED = LED;