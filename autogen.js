var AUTOGEN_START = "//~autogen";
var AUTOGEN_LIQUID_START = "/*";
var AUTOGEN_LIQUID_END = "*/";
var AUTOGEN_END = AUTOGEN_START;

var liquidEngine = new (require("liquid-node").Engine)();
var fs = require('fs');

liquidEngine.registerFilters({
    camel_case: function (input) {
        return String(input).toLowerCase().replace(/[-|\s](.)/g, function (match, group1) {
            return group1.toUpperCase();
        });
    }
});

var specData = JSON.parse(fs.readFileSync("spec.json"));
var filesToProcess = fs.readFileSync("autogen-list.txt").toString().split('\n');

for (var i in filesToProcess) {
    processFile(filesToProcess[i].trim(), specData, function (err) {
        if (err)
            console.log("Error processing file \"" + filesToProcess[i] + "\": " + err);
        else
            console.log("Completed processing file \"" + filesToProcess[i] + "\"");
    });
}

function processFile(filename, specData, callback) {
    fs.readFile(filename, function (err, data) {
        if (err) {
            callback(err);
            return;
        }

        processAutogenBlock(data.toString(), 0, function (result) {
            fs.writeFile(filename, result, {}, callback);
        });
    });
}

function processAutogenBlock(allData, pos, callback) {
    if ((pos = allData.indexOf(AUTOGEN_START, pos)) == -1)
    {
        callback(allData);
        return;
    }

    pos += AUTOGEN_START.length;

    var startBlock = pos;
    var startLiquid = allData.indexOf(AUTOGEN_LIQUID_START, startBlock) + AUTOGEN_LIQUID_START.length;
    var endLiquid = allData.indexOf(AUTOGEN_LIQUID_END, startLiquid);
    var endBlock = allData.indexOf(AUTOGEN_END, endLiquid + AUTOGEN_LIQUID_END.length);

    var liquid = allData.substring(startLiquid, endLiquid);

    liquidEngine
        .parseAndRender(liquid, specData)
        .then(function (result) {
            var newData =
                allData.substring(0, endLiquid + AUTOGEN_LIQUID_END.length)
                + result
                + allData.substring(endBlock);

            processAutogenBlock(newData,
                endLiquid
                + AUTOGEN_LIQUID_END.length
                + result.length
                + AUTOGEN_END.length, callback);
        });
}