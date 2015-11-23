//Extension and helper methods
exports.regexIndexOf = function (text, regex, startpos) {
    var indexOf = text.substring(startpos || 0).search(regex);
    return (indexOf >= 0) ? (indexOf + (startpos || 0)) : indexOf;
}

//Removes all elements with a specific value from an array (defaults to blank string)
exports.cleanArray = function (array, deleteValue) {
    if (deleteValue == undefined)
        deleteValue = '';
    for (var i = 0; i < array.length; i++) {
        if (array[i] == deleteValue) {
            array.splice(i, 1);
            i--;
        }
    }
    return array;
};


//Copies properties of one or more objects in to the first object (same as jQuery's extend method)
exports.extend = function() {
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
//  ...is the same as:
//  setProp(foo, 'bar.abc', 8);
exports.setProp = function(object, property, value) {
    if (typeof property == 'string')
        property = property.split('.');

    if (property.length < 1)
        return;

    var first = property.shift();
    if (property.length == 0)
        object[first] = value;
    else
        exports.setProp(object[first], property, value);
}

//ex:
//  var x = foo['bar']['abc'];
//  ...is the same as:
//  var x = getProp(foo, 'bar.abc');
exports.getProp = function(object, property) {

    if (object == undefined || property.length < 1)
        return undefined;

    if (typeof property == 'string')
        property = property.split('.');

    var first = property.shift();
    if (property.length == 0)
        return object[first];
    else
        return exports.getProp(object[first], property);
}


exports.parseAutogenTag = function (tagText) {
    var templateFileName = '';

    var currentIndex = 0;
    for (; tagText[currentIndex] != ' ' && currentIndex < tagText.length; currentIndex++) {
        templateFileName += tagText[currentIndex];
    }
    
    var mappingData = getMappingData(tagText, currentIndex + 1);

    return {
        templateFileName: templateFileName,
        propertyMappings: mappingData.propertyMappings,
        valueMappings: mappingData.valueMappings
    };
}

function getMappingData(tagText, startIndex) {
    var foundMappings = {
        propertyMappings: [],
        valueMappings: []
    };

    var currentNestedQuoteType = undefined;
    var hasFoundAngleBracket = false;

    var defaultMappingData = {
        type: 'property',
        sourceString: '',
        destString: ''
    };

    var currentMappingData = exports.extend({}, defaultMappingData);

    for (var currentIndex = startIndex; currentIndex < tagText.length; currentIndex++) {
        var currentChar = tagText[currentIndex];

        if (isQuote(currentChar)) {
            if (currentNestedQuoteType == undefined) {
                currentNestedQuoteType = currentChar;
                currentMappingData.type = 'value';
            }
        }
        else if (currentNestedQuoteType == undefined && currentChar == ">") {
            hasFoundAngleBracket = true;
            continue;
        }

        if((currentNestedQuoteType != undefined && currentChar != currentNestedQuoteType)
                || (currentNestedQuoteType == undefined && !isWhitespace(currentChar))) {
            if (hasFoundAngleBracket)
                currentMappingData.destString += currentChar;
            else
                currentMappingData.sourceString += currentChar;
        }

        if (currentNestedQuoteType == undefined && (isWhitespace(currentChar) || currentIndex + 1 >= tagText.length)) {
            if(currentMappingData.sourceString.length <= 0 || currentMappingData.destString.length <= 0)
                continue;
            
            if (currentMappingData.type == 'property')
                foundMappings.propertyMappings.push(currentMappingData);
            else
                foundMappings.valueMappings.push(currentMappingData);

            currentMappingData = exports.extend({}, defaultMappingData)
            hasFoundAngleBracket = false;
        }
        
        if (isQuote(currentChar)) {
            if (currentChar == currentNestedQuoteType)
                currentNestedQuoteType = undefined;
        }
    }

    return foundMappings;
}

function isWhitespace(text) {
    return text.trim().length <= 0;
}

function isQuote(char) {
    return char == '"' || char == "'";
}