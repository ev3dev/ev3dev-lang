///<reference path="node.d.ts" />

/*
 * This is a language binding for the ev3dev device APIs. More info at: https://github.com/ev3dev/ev3dev-lang
 * This library complies with spec v0.9.1
 */


var fs = require('fs');
var path = require('path');
//var Enumerable: linqjs.EnumerableStatic = require('linq');

/* CONSTANTS */

var ports = {
    INPUT_AUTO: undefined,
    OUTPUT_AUTO: undefined,

    INPUT_1: 'in1',
    INPUT_2: 'in2',
    INPUT_3: 'in3',
    INPUT_4: 'in4',

    OUTPUT_A: 'outA',
    OUTPUT_B: 'outB',
    OUTPUT_C: 'outC',
    OUTPUT_D: 'outD'
}