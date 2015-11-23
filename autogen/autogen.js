// Node.JS script to evaluate custom liquid templates in files

var os = require('os');
var path = require('path');
var fs = require('fs');
var argv = require('yargs').argv;

var config = require('./config.js');
var utils = require('./utils.js');
var core = require('./autogen-core.js');

//Load the liquid engine
var liquidEngine = new (require("liquid-node").Engine)();

//Register custom liquid filters
liquidEngine.registerFilters(config.extraLiquidFilters);

//Load the spec data and list of files to process
var specData = JSON.parse(fs.readFileSync(path.resolve(__dirname, "spec.json")));
var groupsToProcess = getGroupsToProcess();

if (groupsToProcess.length > 0)
    console.log("Queuing " + groupsToProcess.length + " file groups...");
else
    console.log("Warning: No matching file groups found!");

var clearTemplatedSections = false;
if (argv.x || argv.clear)
    clearTemplatedSections = true;


//Call the process function on each specified file, and log the result
for (var groupIndex = 0; groupIndex < groupsToProcess.length; groupIndex++) {
    for (var fileIndex = 0; fileIndex < groupsToProcess[groupIndex].files.length; fileIndex++) {
        var filePath = groupsToProcess[groupIndex].files[fileIndex];
        var templateDir = path.resolve(__dirname, '..', groupsToProcess[groupIndex].templateDir);;

        var autogenContext = {
            filePath: filePath,
            templateDir: templateDir,
            specData: specData,
            liquidEngine: liquidEngine,
            clearTemplatedSections: clearTemplatedSections
        }

        core.bootstrapFileProcessor(autogenContext, function (filename, err) {
            if (err)
                console.log("Error processing file \"" + filename + "\": " + err);
            else
                console.log("Completed processing file \"" + filename + "\"");
        });
    }
}

function getGroupsToProcess() {
    //Load the list of files to process
    var groupDefinitions = JSON.parse(fs.readFileSync(path.resolve(__dirname, "autogen-list.json")).toString());

    var groupsToProcess = [];

    //Only queue the files from the group that was specified
    for (var groupName in groupDefinitions) {
        if (argv._.indexOf(groupName) != -1)
            groupsToProcess.push(groupDefinitions[groupName]);
    }

    return groupsToProcess;
}