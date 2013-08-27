# Runs the server

net = require 'net'
ursa = require 'ursa'
fs = require 'fs'
Connection = require './connection'

# Server
# ======
# Instantiates a server to listen for connections from the clients and to manage
# who all is connected to it.
class Server
	# constructor
	# -----------
	# Creates an empty offline server.
	constructor: ->
		@connections = []
		privateKeyPem = fs.readFileSync 'data/key', 'utf8'
		@privateKey = ursa.createPrivateKey privateKeyPem, '', 'utf8'
		
	# start
	# -----
	# Starts the server.  
	# `config` - The configuration object. Normally read using `configloader`.  
	# `debug` - Optional. Set to true if debug messages should be sent to the
	# console.
	start: (@config, debug = false) =>
		@server = net.createServer (c) =>
			conn = new Connection c, @privateKey
			
			@connections.push conn
			
			conn.onData (data) =>
				console.log "#{@connections.length} connections"

			conn.onEnd =>
				@connections.splice index, 1 for index, value of @connections when value is conn
		
		@server.listen config.port, =>
			console.log "Listening on port #{ @config.port }"

		if debug
			setInterval =>
				console.log "#{@connections.length} connections"
			, 3000


module.exports = Server


