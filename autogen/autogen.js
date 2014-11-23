// Node.JS script to evaluate custom liquid templates in files

//TODO: Detect correct comment style based on file extension
var AUTOGEN_START = "//~autogen";
var AUTOGEN_END = AUTOGEN_START;

//Extension and helper methods
String.prototype.regexIndexOf = function(regex, startpos) {
    var indexOf = this.substring(startpos || 0).search(regex);
    return (indexOf >= 0) ? (indexOf + (startpos || 0)) : indexOf;
}


//Copies properties of one or more objects in to the first object (same as jQuery's extend methos)
function extend() {
    for (var i = 1; i < arguments.length; i++)
        for (var key in arguments[i])
            if (arguments[i].hasOwnProperty(key))
                arguments[0][key] = arguments[i][key];
    return arguments[0];
}

// getProp and setProp function like bracket notation,
//   but accept dot notation as the indexer,
//   allowing deep access of dynamic objects.

//ex:
//  foo['bar']['abc'] = 8;
//  setProp(foo, 'bar.abc', 8);
function setProp(object, property, value) {
    if(typeof property == 'string')
        property = property.split('.');

    if(property.length < 1)
        return;

    var first = property.shift();
    if(property.length == 0)
        object[first] = value;
    else
        setProp(object[first], property, value);
}

//ex:
//  var x = foo['bar']['abc'];
//  var x = getProp(foo, 'bar.abc');
function getProp(object, property) {
    if (typeof property == 'string')
        property = property.split('.');

    if (property.length < 1)
        return;

    var first = property.shift();
    if (property.length == 0)
        return object[first];
    else
        return getProp(object[first], property);
}

//Load the liquid engine
var liquidEngine = new (require("liquid-node").Engine)();
var fs = require('fs');

//Generic require
var os = require('os');
var path = require('path');

//Register custom liquid filters
liquidEngine.registerFilters({
    camel_case: function (input) {
        return String(input).toLowerCase().replace(/[-|\s](.)/g, function (match, group1) {
            return group1.toUpperCase();
        });
    }
});

//Load the spec data and list of files to process
var specData = JSON.parse(fs.readFileSync("spec.json"));
var filesToProcess = fs.readFileSync("autogen-list.txt").toString().split('\n');

//Call the process function on each file, and log the result
for (var i in filesToProcess) {
    processFile(filesToProcess[i].trim(), specData, function (filename, err) {
        if (err)
            console.log("Error processing file \"" + filename + "\": " + err);
        else
            console.log("Completed processing file \"" + filename + "\"");
    });
}

//Processes the contents of the specified file, and writes the result back to the same location (uses recursion)
function processFile(filename, specData, callback) {
    fs.readFile(filename, function (err, data) {
        if (err) {
            callback(filename, err);
            return;
        }

        processNextAutogenBlock(data.toString(), 0, function (result) {
            fs.writeFile(filename, result, {}, function (err) {
                callback(filename, err);
            });
        });
    });
}

//Recursively updates the autogen blocks
function processNextAutogenBlock(allData, pos, callback) {

    //Update the position of the next block. If there isn't one, call the callback and break the recursion.
    if ((pos = allData.indexOf(AUTOGEN_START, pos)) == -1)
    {
        callback(allData);
        return;
    }

    //Skip over the start tag
    pos += AUTOGEN_START.length;

    //Calculate the bounds of the target content
    //TODO: Use a single regex w/ capture groups for the autogen definition
    var startAutogenDef = allData.regexIndexOf(/[^\s]/, pos);
    var endAutogenDef = allData.regexIndexOf(/\r|\n/, startAutogenDef);
    var startBlock = allData.regexIndexOf(/[^\r\n]/, endAutogenDef)
    var endBlock = allData.indexOf(AUTOGEN_END, startBlock);

    //Extract the required info from the block
    var liquidInfo = allData.substring(startAutogenDef, endAutogenDef).trim().split(' ');
    var filename = path.join("templates", liquidInfo.shift() + ".liquid");
    
    //Prepare the required data
    var loadedLiquid = fs.readFileSync(filename);
    //Deep-copy the spec data so that we can add context
    var liquidContext = extend({}, specData);

    //Iterate over the remaining chunks in the autogen definition and
    //  copy the requested data from the spec to the liquid context
    for (var i in liquidInfo) {
        var defParts = liquidInfo[i].split(">");
        setProp(liquidContext, defParts[1], getProp(liquidContext, defParts[0]));
    }
    
    //Parse and render the liquid using the spec data
    liquidEngine
        .parseAndRender(loadedLiquid, liquidContext)
        .then(function (result) {
            //Replace the old contents of the output block with the result from the liquid engine
            var newData =
                allData.substring(0, startBlock)
                + result
                + os.EOL
                + allData.substring(endBlock);

            //Start/continue the recursion, and update the position for the next iteration
            processNextAutogenBlock(newData,
                startBlock
                + result.length
                + os.EOL.length
                + AUTOGEN_END.length, callback);
        });
}