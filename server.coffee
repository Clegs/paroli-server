# server2.coffee - Runs the server

class Server
	constructor: ->
		@net = require 'net'
		
	# Starts a new server from the given config file.
	start: (config) ->
		@server = @net.createServer (c) ->
			console.log 'Server Started'
			c.write 'User Connected\r\n'

			# Create an empy user object to keep track of the user's session.
			user = {}

			c.on 'end', ->
				console.log 'Server Disconnected'
			c.on 'data', (data) ->
				console.log "Received: #{ data }"

		@server.listen config.port, ->
			console.log "Listening on port #{ config.port }"


module.exports = Server


