# server.coffee - Runs the server

net = require 'net'
ursa = require 'ursa'
fs = require 'fs'
Connection = require './connection'

class Server
	constructor: ->
		@connections = []
		privateKeyPem = fs.readFileSync 'data/key', 'utf8'
		@privateKey = ursa.createPrivateKey privateKeyPem, '', 'utf8'
		
	# Starts a new server from the given config file.
	start: (@config, debug = false) =>
		@server = net.createServer (c) =>
			conn = new Connection c, @privateKey
			
			@connections.push conn
			
			conn.onData (data) =>
				console.log "#{@connections.length} connections"

			conn.onEnd =>
                @connections.splice index, 1 for index, value of @connections when value is conn

        console.log config.port
		@server.listen config.port, =>
			console.log "Listening on port #{ @config.port }"

		if debug
			setInterval =>
				console.log "#{@connections.length} connections"
			, 3000


module.exports = Server


