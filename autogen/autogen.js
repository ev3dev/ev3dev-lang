// Node.JS script to evaluate custom liquid templates in files

//Explanation of C-style regex here: http://regex101.com/r/nQ9bE3
var cStyleAutogenStart = /\/\/~autogen *([\w-]+) *((\s*[\w\."']+>[\w\.]+)*)/;
var cStyleAutogenEnd = "//~autogen";

//TODO: allow a regex for the end tag (so that we can be more lenient on spacing)
//Array of objects containing the language-specific comment styles. "start" can be a regex (described below).
//    The first capture group should get the file name from the autogen tag.
//    The second should be a space-separated list of variable mappings, as written in the comment.
var autogenFenceComments = {
    '.ts': { start: cStyleAutogenStart, end: cStyleAutogenEnd },
    '.vala': { start: cStyleAutogenStart, end: cStyleAutogenEnd },
    '.cpp': { start: cStyleAutogenStart, end: cStyleAutogenEnd },
    '.h': { start: cStyleAutogenStart, end: cStyleAutogenEnd },
    //XML-style regex here: http://regex101.com/r/cN6gE4
    '.md': { start: /<!--\s*~autogen *([\w-]+) *((\s*[\w\."']+>[\w\.]+)*)\s*-->/, end: "<!-- ~autogen -->" },
    //Lua regex: http://regex101.com/r/mI4gL1
    '.lua': { start: /-- *~autogen *([\w-]+) *((\s*[\w\."']+>[\w\.]+)*)/, end: "-- ~autogen" }
}

//Extension and helper methods
String.prototype.regexIndexOf = function(regex, startpos) {
    var indexOf = this.substring(startpos || 0).search(regex);
    return (indexOf >= 0) ? (indexOf + (startpos || 0)) : indexOf;
}

//Removes all elements with a specific value from an array (defaults to blank string)
Array.prototype.clean = function (deleteValue) {
    if (deleteValue == undefined)
        deleteValue = '';
    for (var i = 0; i < this.length; i++) {
        if (this[i] == deleteValue) {
            this.splice(i, 1);
            i--;
        }
    }
    return this;
};


//Copies properties of one or more objects in to the first object (same as jQuery's extend method)
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

    if (object == undefined || property.length < 1)
        return undefined;

    if (typeof property == 'string')
        property = property.split('.');

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
    camel_case: function (input) { //camel-cases the input string
        return String(input).toLowerCase().replace(/[-|\s](.)/g, function (match, group1) {
            return group1.toUpperCase();
        });
    },
    underscore_spaces: function (input) { //replaces sections of whitespace with underscores
        return String(input).replace(/\s/g, '_');
    },
    underscore_non_wc: function (input) { //replaces non-word characters with underscores
        return String(input).replace(/\W/g, '_');
    },
    ternary_if: function (bool, valueIfTrue, valueIfFalse) { //ternary switch statement (also converts undefined values to blank string automatically)
        return bool ? (valueIfTrue == undefined ? '' : valueIfTrue ) : (valueIfFalse == undefined ? '' : valueIfFalse );
    },
    traverse_object: function (object, property) { //gets a property from an object
        return getProp(object, Array.prototype.slice.call(arguments, 1).join("."));
    },
    append_to_array: function (elements) { //creates an array from the given arguments
        return Array.prototype.slice.call(arguments, 0);
    },
    eq: function (a, b) { //equality comparison (used to get around lack of grouping in liquid)
        return a == b;
    },
    eval: function (expression, context) { //evaluates expression as JavaScript in the given context
        var vm = require('vm');
        return vm.runInNewContext(expression, context || {});
    }
});


//Load the spec data and list of files to process
var specData = JSON.parse(fs.readFileSync(path.resolve(__dirname, "spec.json")));
var fileDefinitions = JSON.parse(fs.readFileSync(path.resolve(__dirname, "autogen-list.json")).toString());
var args = process.argv.slice(2);

var filesToProcess = [];

//Only queue the files from the group that was specified (or default to all)
for(var i in fileDefinitions)
    if(args.length <= 0 || args.indexOf(i) >= 0)
        filesToProcess.push.apply(filesToProcess, fileDefinitions[i]);

if (filesToProcess.length > 0)
    console.log(filesToProcess.length + " files found");
else
    console.log("Warning: No files found");


//Call the process function on each specified file, and log the result
for (var i = 0; i < filesToProcess.length; i++) {
    var commentInfo = autogenFenceComments[path.extname(filesToProcess[i])];
    
    processFile(filesToProcess[i].trim(), specData, commentInfo, function (filename, err) {
        if (err)
            console.log("Error processing file \"" + filename + "\": " + err);
        else
            console.log("Completed processing file \"" + filename + "\"");
    });
}

//Processes the contents of the specified file, and writes the result back to the same location (uses recursion)
function processFile(filename, specData, commentInfo, callback) {
    fs.readFile(path.resolve(__dirname, "..", filename), function (err, data) {
        if (err) {
            callback(filename, err);
            return;
        }

        processNextAutogenBlock(data.toString(), commentInfo, 0, function (result) {
            if (data.toString() != result) //Write results if the content was changed (don't need to re-write the same content)
                fs.writeFile(path.resolve(__dirname, "..", filename), result, {}, function (err) {
                    callback(filename, err);
                });
            else
                callback(filename, err);
        });
    });
}

//Recursively updates the autogen blocks
function processNextAutogenBlock(allData, commentInfo, pos, callback) {
    //Update the position of the next block. If there isn't one, call the callback and break the recursion.
    if (commentInfo.start instanceof RegExp)
        pos = allData.regexIndexOf(commentInfo.start, pos);
    else
        pos = allData.indexOf(commentInfo.start, pos);

    if (pos == -1)
    {
        callback(allData);
        return;
    }
    
    var liquidInfo, filename;

    //Extract the information from the autogen definition
    if (commentInfo.start instanceof RegExp) { //Use a regex if it was supplied (much cleaner and less prone to errors)
        var matchInfo = commentInfo.start.exec(allData.substring(pos));
        
        //Skip over the start tag
        pos += matchInfo[0].length;

        //Get the data from the capture groups
        filename = matchInfo[1];
        liquidInfo = matchInfo[2].trim().split(' ').clean();
    }

    else { //Generic search to handle C-style comments (better to use regular expressions, this is just a backup)
        //Skip over the start tag
        pos += commentInfo.start.length;

        //Calculate the bounds of the target content using separate regex
        var startAutogenDef = allData.regexIndexOf(/[^\s]/, pos);
        var endAutogenDef = allData.regexIndexOf(/\r|\n/, startAutogenDef);

        //Extract the required info from the block
        liquidInfo = allData.substring(startAutogenDef, endAutogenDef).trim().split(' ').clean();
        filename = liquidInfo.shift();
    }

    //Make file name in to a full path
    filename = path.resolve(__dirname, "templates", filename + ".liquid");
    
    //Find the end of the line (and the start of content)
    //    Handle both styles of line endings
    var endOfAutogenLine = allData.regexIndexOf(/[\r|\n]/, pos);
    var startBlock = allData.regexIndexOf(/[\n]/, endOfAutogenLine) + 1;
    var endBlock = allData.indexOf(commentInfo.end, startBlock);

    //Prepare and load the required data
    var loadedLiquid = fs.readFileSync(filename);
    //Deep-copy the spec data so that we can add context
    var liquidContext = extend({}, specData);

    //Iterate over the remaining chunks in the autogen definition and
    //    copy the requested data from the spec to the liquid context
    for (var i = 0; i < liquidInfo.length; i++) {
        var defParts = liquidInfo[i].split(">");
        var propValue = getProp(liquidContext, defParts[0]);

        //If the property wasn't found, treat it as a plain string
        if (propValue == undefined) {
            //Trim quotes (for string literals)
            propValue = defParts[0].replace(/^["']+|["']+$/g, '');
        }

        setProp(liquidContext, defParts[1], propValue);
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
            processNextAutogenBlock(newData, commentInfo,
                startBlock
                + result.length
                + os.EOL.length
                + commentInfo.end.length, callback);
        });
}
