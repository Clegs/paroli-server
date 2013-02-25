# This program will setup the data directories for the server.
# Please remove the 'data' folder if it already exists.

fs = require 'fs'

# Check to make sure there is no data directory.
# If it exists than exit immediatly.
if fs.existsSync 'data'
	console.log 'The \'data\' directory already exists.'
	process.exit 1

# Create the following directories in the order listed.
directories = [
               'data'
               'data/users'
			   'data/groups'
			  ]

for dir in directories
	console.log "Creating: #{dir}"
	fs.mkdirSync dir

