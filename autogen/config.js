//Explanation of C-style regex here: http://regex101.com/r/nQ9bE3
var cStyleAutogenStart = /\/\/~autogen *([\w-]+) *((\s*[\w\."',]+>[\w\.]+)*)/;
var cStyleAutogenEnd = "//~autogen";

//TODO: allow a regex for the end tag (so that we can be more lenient on spacing)
//Array of objects containing the language-specific comment styles. "start" can be a regex (described below).
//    The first capture group should get the file name from the autogen tag.
//    The second should be a space-separated list of variable mappings, as written in the comment.
exports.autogenFenceComments = {
    '.ts': { start: cStyleAutogenStart, end: cStyleAutogenEnd },
    '.vala': { start: cStyleAutogenStart, end: cStyleAutogenEnd },
    '.cpp': { start: cStyleAutogenStart, end: cStyleAutogenEnd },
    '.h': { start: cStyleAutogenStart, end: cStyleAutogenEnd },
    '.java': { start: cStyleAutogenStart, end: cStyleAutogenEnd },
    //XML-style regex here: http://regex101.com/r/cN6gE4
    '.md': { start: /<!--\s*~autogen *([\w-]+) *((\s*[\w\."',]+>[\w\.]+)*)\s*-->/, end: "<!-- ~autogen -->" },
    //Lua regex: http://regex101.com/r/mI4gL1
    '.lua': { start: /-- *~autogen *([\w-]+) *((\s*[\w\."',]+>[\w\.]+)*)/, end: "-- ~autogen" },
    '.py': { start: /# ~autogen *([\w-]+) *((\s*[\w\."',]+>[\w\.]+)*)/, end: "# ~autogen" }
}

exports.extraLiquidFilters = {
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
        return bool ? (valueIfTrue == undefined ? '' : valueIfTrue) : (valueIfFalse == undefined ? '' : valueIfFalse);
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
};