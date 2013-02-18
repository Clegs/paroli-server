// server.js - Runs the server

module.exports = {};

var net = require('net');
var server;


// Starts a new server from the given config file.
module.exports.start = function(config) {
	server = net.createServer(function(c) { // Connection Listener
		console.log('Server Started');
		c.write('User Connected\r\n');
		
		// Create an empty user object to keep track of the users session.
		var user = {};
		
		c.on('end', function() {
			console.log('Server Disconnected');
		});
		c.on('data', function(data) {
			console.log('Received: %s', data);
		});
	});
	
	server.listen(config.port, function() {
		console.log('Listening on port %d', config.port);
	});
};


