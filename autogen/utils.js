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
