/**
* $.parseParams - parse query string paramaters into an object.
*/
(function($) {
var re = /([^&=]+)=?([^&]*)/g;
var decodeRE = /\+/g; // Regex for replacing addition symbol with a space
var decode = function (str) {return decodeURIComponent( str.replace(decodeRE, " ") );};
$.parseParams = function(query) {
    var params = {}, e;
    while ( e = re.exec(query) ) {
        var k = decode( e[1] ), v = decode( e[2] );
        if (k.substring(k.length - 2) === '[]') {
            k = k.substring(0, k.length - 2);
            (params[k] || (params[k] = [])).push(v);
        }
        else params[k] = v;
    }
    return params;
};
})(jQuery);

/**
* str.QueryStringToJSON() - parse query string paramaters into an object.
*/
String.prototype.QueryStringToJSON = function () {
href = this;
qStr = href.replace(/(.*?\?)/, '');
qArr = qStr.split('&');
stack = {};
for (var i in qArr) {
    var a = qArr[i].split('=');
    var name = a[0],
        value = isNaN(a[1]) ? a[1] : parseFloat(a[1]);
    if (name.match(/(.*?)\[(.*?)]/)) {
        name = RegExp.$1;
        name2 = RegExp.$2;
        //alert(RegExp.$2)
        if (name2) {
            if (!(name in stack)) {
                stack[name] = {};
            }
            stack[name][name2] = value;
        } else {
            if (!(name in stack)) {
                stack[name] = [];
            }
            stack[name].push(value);
        }
    } else {
        stack[name] = value;
    }
}
return stack;
}
