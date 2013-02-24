# configloader2.coffee - Reads the config file and returnes
# the configuration as an object

module.exports = {}

# Default values. Don't edit these, instead configure the 'config' file.
module.exports.name = "Paroli Server"
module.exports.port = 6743

fs = require 'fs'

data = fs.readFileSync 'config', 'utf8'
lines = data.split '\n'

lines.forEach (line) ->
	line = line.trim()
	if line.length is 0
		return # Empty line
	if line.substring 0, 1 is '#'
		return # Comment, do nothing
	
	space = line.indexOf ' '
	if space is -1
		return;
	
	if space is line.length - 1
		return
	
	key = line.substring 0, space
	value = line.substring space + 1
	if not isNaN value
		value = parseInt value
	
	module.exports[key] = value
