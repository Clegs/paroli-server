###
# connection.coffee - Manages the communication between the client and server.
###

fs = require 'fs'
async = require 'async'
crypto = require 'crypto'
Encryption = require './encryption'

class Connection
	constructor: (@c, @privateKey) ->
		# Setup a new connection
		console.log "Connection Started"

		# Perform handshake
		async.waterfall [
			(callback) =>
				fs.readFile 'data/key.pub', 'utf8', (err, data) =>
					if err
						@c.write "Could not load pulbic key\r\n"
						@c.end()
						callback err
						return

					# Listen for the connection ending
					@c.on 'end', @end
					callback null, data
			(publicKey, callback) =>
				@c.once 'data', (data) =>
					# They have now sent the key
					@c.on 'data', @data
					@key = privateKey.decrypt data
					console.log "Key: #{@key}"
					@enc = new Encryption @key, @privateKey
					callback null

				@c.write publicKey
			(callback) =>
				# Listen for data
				#@c.on 'data', @data
				callback null
		]
	
	# Called when the client disconnects from the server.
	# Optional: Pass terminate = true for the server to disconnect on the client.
	end: (terminate = false) =>
		# End the connection
		@c.end()
		console.log "Connection Disconnected"
		@endFunc?(@c)

	data: (data) =>
		d = @enc.decObj data
		console.log "Received: #{JSON.stringify d}"

		response = {}

		if d.command?
			switch d.command
				when "login"
					response.success = true
				else
					response.message = "Unknown command"
		
		res = @enc.encObj response
		console.log "Sending: #{res}"
		@c.write res


		@dataFunc?(data)

	
	###
		Events Associated With A Connection
	###
	# Call this function when the connection is terminated.
	onEnd: (@endFunc) =>

	onData: (@dataFunc) =>


# Export the Connection class
module.exports = Connection

