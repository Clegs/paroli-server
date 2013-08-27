# Reads the config file and returnes the configuration as an object

fs = require 'fs'

# Default values. Don't edit these, instead configure the 'config' file.
module.exports =
    name: "Paroli Server"
    port: 6743

data = fs.readFileSync './config', 'utf8'
lines = data.split '\n'

for line in lines
    line = line.trim()
    if line.length is 0
return
    # Empty line
    if line.substring 0, 1 is '#'
return
    # Comment, do nothing

    space = line.indexOf ' '
    if space is -1
return

    if space is line.length - 1
return

    key = line.substring 0, space
    value = line.substring space + 1
    unless isNaN value
        value = parseInt value

    module.exports[key] = value

# [Cloud9](http://c9.io) Support - Has not been tested.
module.exports.port = process.env.PORT if process.env.PORT?
