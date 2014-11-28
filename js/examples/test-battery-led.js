var ev3dev = require('../bin/index.js');


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
console.log('fading LEDs from green to red...');
var leds = [];
[   'ev3:green:left',  'ev3:red:left',
    'ev3:green:right', 'ev3:red:right'
].forEach(function (value) {
    leds.push(new ev3dev.LED(value));
});

//Just running through the properties isn't helpful as a test
//    This will transition through the range of colors

for(var i = 0; i < 100; i++) {
    for(var ledI = 0; ledI < leds.length; ledI++) {
        var val = (i / 100) * leds[ledI].maxBrightness;
        if(ledI % 2 == 0)
            val = (100 - i) / 100 * leds[ledI].maxBrightness; 
        
        leds[ledI].brightness = Math.round(val);
    }
    
    if(i % 10 == 0)
        console.log(i + '%');
    
    {   //Hack to sleep for time
        //    SHOULD NOT BE USED IN PRODUCTION CODE
        var stop = new Date().getTime();
        while(new Date().getTime() < stop + 100) {
            ;
        }
    }
}

console.log('done');

for(var i in leds) {
    leds[i].brightness = 0;
}

console.log('--------------------')