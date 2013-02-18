// configloader.js - Reads the config file and returns the
// configuration as an object.

module.exports = {};

// Default values. Don't edit thiese, instead configure the 'config' file.
module.exports.name = "Paroli Server";
module.exports.port = 6743;

var fs = require('fs');

var data = fs.readFileSync('config', 'utf8');
var lines = data.split('\n');

lines.forEach(function(line) {
	line = line.trim();
	if(line.length == 0)
		return; // Empty line
	if(line.substring(0, 1) === '#')
		return; // Comment, do nothing
	
	var space = line.indexOf(' ');
	if(space == -1)
		return;
	
	if(space == line.length - 1)
		return;

	var key = line.substring(0, space);
	var value = line.substring(space + 1);
	if(!isNaN(value))
		value = parseInt(value);
	
	module.exports[key] = value;
});

