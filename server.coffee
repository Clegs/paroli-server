# server.coffee - Runs the server

net = require 'net'
Connection = require './connection'

class Server
	constructor: ->
		@connections = []
		
	# Starts a new server from the given config file.
	start: (config, debug = false) =>
		@config = config

		@server = net.createServer (c) =>
			conn = new Connection(c)
			
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


