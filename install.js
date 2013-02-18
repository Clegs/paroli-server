#!/usr/bin/env node

// This program will setup the data directories for the server.
// Please remove the 'data' folder if it already exists.

var fs = require('fs');

// Check to make sure there is no data directory.
// If it exists than exit immediatly.
if(fs.existsSync('data')) {
	console.log('The \'data\' directory already exists.');
	process.exit(1); // Report failure to run.
}

// Create the following directories in the order listed.
var directories = ['data',
                   'data/users',
                   'data/groups'];

directories.forEach(function(dir) {
	console.log('Creating: ' + dir);
	fs.mkdirSync(dir);
});


