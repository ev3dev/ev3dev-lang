// Node.JS script to evaluate custom liquid blocks in files

var AUTOGEN_START = "//~autogen";
var AUTOGEN_LIQUID_START = "/*";
var AUTOGEN_LIQUID_END = "*/";
var AUTOGEN_END = AUTOGEN_START;

//Load the liquid engine
var liquidEngine = new (require("liquid-node").Engine)();
var fs = require('fs');

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
    processFile(filesToProcess[i].trim(), specData, function (err) {
        if (err)
            console.log("Error processing file \"" + filesToProcess[i] + "\": " + err);
        else
            console.log("Completed processing file \"" + filesToProcess[i] + "\"");
    });
}

//Processes the contents of the specified file, and writes the result back to the same location
function processFile(filename, specData, callback) {
    fs.readFile(filename, function (err, data) {
        if (err) {
            callback(err);
            return;
        }

        processNextAutogenBlock(data.toString(), 0, function (result) {
            fs.writeFile(filename, result, {}, callback);
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

    //Calculate the bounds of the outer block and inner liquid comment
    var startBlock = pos;
    var startLiquid = allData.indexOf(AUTOGEN_LIQUID_START, startBlock) + AUTOGEN_LIQUID_START.length;
    var endLiquid = allData.indexOf(AUTOGEN_LIQUID_END, startLiquid);
    var endBlock = allData.indexOf(AUTOGEN_END, endLiquid + AUTOGEN_LIQUID_END.length);

    //Extract the liquid string from the current block
    var liquid = allData.substring(startLiquid, endLiquid);

    //Parse and render the liquid using the spec data
    liquidEngine
        .parseAndRender(liquid, specData)
        .then(function (result) {
            //Replace the old contents of the output block with the result from the liquid engine
            var newData =
                allData.substring(0, endLiquid + AUTOGEN_LIQUID_END.length)
                + result
                + allData.substring(endBlock);

            //Start the recursion, and update the position for the next iteration
            processNextAutogenBlock(newData,
                endLiquid
                + AUTOGEN_LIQUID_END.length
                + result.length
                + AUTOGEN_END.length, callback);
        });
}