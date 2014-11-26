var ev3dev = require('../bin/index.js');

// Run motor
console.log('Motor --------------');
var motor = new ev3dev.Motor();
['dutyCycle', 'dutyCycleSp', 'portName', 'position',
    'positionSp', 'pulsesPerSecond', 'pulsesPerSecondSp',
    'rampDownSp', 'rampUpSp', 'regulationMode', 'run',
    'runMode', 'speedRegulationP', 'state', 'stopMode',
    'stopModes', 'timeSp', 'type'
].forEach(function (value) {
    console.log(value + ": " + motor[value]);
});

console.log('Setting motor properties...');
motor.rampUpSp = 100;
motor.rampDownSp = 100;
motor.runMode = 'time';
motor.timeSp = 1000;
motor.dutyCycleSp = 50;
console.log('Running motor...');
motor.run = 1;
console.log('--------------------');

//Read sensor
console.log('Sensor -------------');
var sensor = new ev3dev.Sensor();
[ 'portName', 'numValues', 'typeName',
    'mode', 'modes'
].forEach(function (value) {
    console.log(value + ": " + sensor[value]);
});

console.log('Testing sensor read...');
for(var i = 0; i < sensor.numValues; i++) {
    console.log('value ' + i + ': ' + sensor.getValue(i) + ', ' + sensor.getFloatValue(i));
}
console.log('--------------------')
console.log("Core motor and sensor test complete");

console.log('Battery ------------');
var battery = new ev3dev.PowerSupply();
[ 'currentNow', 'voltageNow', 'voltageMaxDesign',
    'voltageMinDesign', 'technology', 'type',
    'currentAmps', 'voltageVolts'
].forEach(function (value) {
    console.log(value + ": " + battery[value]);
});
console.log('--------------------')
console.log('LED ----------------');
var leds = [];
[   'ev3:green:left',  'ev3:red:left',
    'ev3:green:right', 'ev3:red:right'
].forEach(function (value) {
    leds.push(new ev3dev.LED(value));
});

//Just running through the properties isn't helpful as a test
//    This will transition through the range of colors

for(var i = 0; i < 1; i += (1/10)) {
    for(var ledI = 0; ledI < leds.length; ledI++) {
        var val = i * leds[ledI].maxBrightness;
        if(ledI % 2 == 0)
            val = (1 - i) * leds[ledI].maxBrightness; 
        
        leds[ledI].brightness = Math.round(val);
    }
    
    {   //Hack to sleep for time
        //    SHOULD NOT BE USED IN PRODUCTION CODE
        var stop = new Date().getTime();
        while(new Date().getTime() < stop + 100) {
            ;
        }
    }
}

for(var i in leds) {
    leds[i].brightness = 0;
}

console.log('--------------------')