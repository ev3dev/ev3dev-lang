var utils = require('./utils.js');

var cStyleAutogenStart = /\/\/\s*~autogen *(.+)/;
var cStyleAutogenEnd = "//~autogen";

exports.autogenFenceComments = {
    '.ts': { start: cStyleAutogenStart, end: cStyleAutogenEnd },
    '.vala': { start: cStyleAutogenStart, end: cStyleAutogenEnd },
    '.cpp': { start: cStyleAutogenStart, end: cStyleAutogenEnd },
    '.h': { start: cStyleAutogenStart, end: cStyleAutogenEnd },
    '.java': { start: cStyleAutogenStart, end: cStyleAutogenEnd },
    '.md': { start: /<!--\s*~autogen *(.+)-->/, end: "<!-- ~autogen -->" },
    '.lua': { start: /--\s*~autogen *(.+)/, end: "-- ~autogen" },
    '.py': { start: /#\s*~autogen *(.+)/, end: "# ~autogen" }
}

exports.extraLiquidFilters = {
    //camel-cases the input string
    camel_case: function (input) {
        return String(input).toLowerCase().replace(/[-|\s](.)/g, function (match, group1) {
            return group1.toUpperCase();
        });
    },
    //replaces sections of whitespace with underscores
    underscore_spaces: function (input) {
        return String(input).replace(/\s/g, '_');
    },
    //replaces non-word characters with underscores
    underscore_non_wc: function (input) {
        return String(input).replace(/\W/g, '_');
    },
    //ternary switch statement (also converts undefined values to blank string automatically)
    ternary_if: function (bool, valueIfTrue, valueIfFalse) {
        return bool ? (valueIfTrue == undefined ? '' : valueIfTrue) : (valueIfFalse == undefined ? '' : valueIfFalse);
    },
    //gets a property from an object
    traverse_object: function (object, property) {
        return utils.getProp(object, Array.prototype.slice.call(arguments, 1).join("."));
    },
    //creates an array from the given arguments
    append_to_array: function (elements) {
        return Array.prototype.slice.call(arguments, 0);
    },
    //equality comparison (used to get around lack of grouping in liquid)
    eq: function (a, b) {
        return a == b;
    },
    //filters the given collection using the provided condition statement, which is
    // evaluated as a JavaScript string (it should return a boolean)
    filter: function(collection, condition) {
        return [].filter(function(item, itemIndex, wholeArray) {
            return eval(condition);
        });
    },
    json_stringify: function(value) {
        return JSON.stringify(value);
    },
    //evaluates expression as JavaScript in the given context
    eval: function (expression, context) {
        var vm = require('vm');
        return vm.runInNewContext(expression, context || {});
    }
};