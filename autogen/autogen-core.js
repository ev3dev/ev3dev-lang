var os = require('os');
var path = require('path');
var fs = require('fs');

var config = require('./config.js');
var utils = require('./utils.js');


exports.bootstrapFileProcessor = function(autogenContext, progress) {
    var commentInfo = config.autogenFenceComments[path.extname(autogenContext.filePath)];

    processFile(autogenContext, commentInfo, progress);
}

//Processes the contents of the specified file, and writes the result back to the same location
function processFile(autogenContext, commentInfo, callback) {
    fs.readFile(path.resolve(__dirname, "..", autogenContext.filePath), function (readError, sourceFileContentsBuffer) {
        if (readError) {
            callback(autogenContext.filePath, readError);
            return;
        }

        processNextAutogenBlock(autogenContext, sourceFileContentsBuffer.toString(), commentInfo, 0, function (result, autogenError) {
            //Write results if the content was changed (don't need to re-write the same content)
            if (sourceFileContentsBuffer.toString() != result)
                fs.writeFile(path.resolve(__dirname, "..", autogenContext.filePath), result, {}, function (writeError) {
                    callback(autogenContext.filePath, writeError);
                });
            else
                callback(autogenContext.filePath, autogenError);
        });
    });
}

//Recursively updates the autogen blocks
function processNextAutogenBlock(autogenContext, allData, commentInfo, pos, callback) {
    if (!(commentInfo.start instanceof RegExp)) {
        var errorStr = "Comment info did not provide regex to use for content parsing!";

        console.error(errorStr + " Skipping file.");
        callback(null, errorStr);

        return;
    }

    //Update the position of the next block. If there isn't one, call the callback and break the recursion.
    pos = utils.regexIndexOf(allData, commentInfo.start, pos);

    if (pos == -1) {
        callback(allData);
        return;
    }

    //Extract the information from the autogen definition
    var matchInfo = commentInfo.start.exec(allData.substring(pos));

    //Skip over the start tag
    pos += matchInfo[0].length;

    //Get the data from the capture groups
    var filename = matchInfo[1];
    var liquidInfo = utils.cleanArray(matchInfo[2].trim().split(' '));

    //Make file name in to a full path
    filename = path.resolve(autogenContext.templateDir, filename + ".liquid");

    //Find the end of the line (and the start of content)
    //    Handle both styles of line endings
    var endOfAutogenLine = utils.regexIndexOf(allData, /[\r|\n]/, pos);
    var startBlock = utils.regexIndexOf(allData, /[\n]/, endOfAutogenLine) + 1;
    var endBlock = allData.indexOf(commentInfo.end, startBlock);

    //Prepare and load the required data
    var loadedLiquid = fs.readFileSync(filename);
    //Deep-copy the spec data so that we can add context
    var dataContext = utils.extend({}, autogenContext.specData);

    //Iterate over the remaining chunks in the autogen definition and
    //    copy the requested data from the spec to the liquid context
    for (var i = 0; i < liquidInfo.length; i++) {
        var defParts = liquidInfo[i].split(">");
        var propValue = utils.getProp(dataContext, defParts[0]);

        //If the property wasn't found, treat it as a plain string
        if (propValue == undefined) {
            //Trim quotes (for string literals)
            propValue = defParts[0].replace(/^["']+|["']+$/g, '');
        }

        utils.setProp(dataContext, defParts[1], propValue);
    }

    function insertTemplatedAndContinue(result) {
        //Replace the old contents of the output block with the result from the liquid engine
        var newData =
            allData.substring(0, startBlock)
            + result
            + os.EOL
            + allData.substring(endBlock);

        //Start/continue the recursion, and update the position for the next iteration
        processNextAutogenBlock(autogenContext, newData, commentInfo,
            startBlock
            + result.length
            + os.EOL.length
            + commentInfo.end.length, callback);
    }

    if (autogenContext.clearTemplatedSections)
        insertTemplatedAndContinue('');
    else {
        //Parse and render the liquid using the spec data
        autogenContext.liquidEngine
            .parseAndRender(loadedLiquid, dataContext)
            .then(insertTemplatedAndContinue);
    }
}
