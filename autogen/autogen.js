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
var specData = JSON.parse(fs.readFileSync(path.resolve(__dirname, "../", "spec.json")));
var targetInfo = getTargetFileInfo();

if(!targetInfo) {
    console.error("No valid config file found! Either specify a path to a '" + config.defaultConfigFileName + "' or 'cd' into a directory that has one.");
    process.exit(1);
}

var clearTemplatedSections = false;
if (argv.x || argv.clear)
    clearTemplatedSections = true;


//Call the process function on each specified file, and log the result
for (var fileIndex = 0; fileIndex < targetInfo.files.length; fileIndex++) {
    var filePath = targetInfo.files[fileIndex];

    var autogenContext = {
        filePath: filePath,
        templateDir: targetInfo.templateDir,
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

function getTargetFileInfo() {
    var pathCandidates = argv._.concat(process.cwd());

    var configFilePath = pathCandidates.map(function(possiblePath) {
        var stat = fs.statSync(possiblePath);

        if(stat.isFile())
            return path.resolve(possiblePath);
        else if (stat.isDirectory())
            return path.resolve(possiblePath, config.defaultConfigFileName);
        else
            return null;

    }).filter(function(configPath) {
        return !!configPath && fs.existsSync(configPath);
    })[0];

    if(!configFilePath)
        return null;

    var loadedTargetFileInfo = JSON.parse(fs.readFileSync(configFilePath).toString());

    return {
        templateDir: path.resolve(path.dirname(configFilePath), loadedTargetFileInfo.templateDir),
        files: loadedTargetFileInfo.files.map(function(configRelativePath) {
            return path.resolve(path.dirname(configFilePath), configRelativePath);
        })
    };
}
