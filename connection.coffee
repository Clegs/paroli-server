###
# connection.coffee - Manages the communication between the client and server.
###

fs = require 'fs'

class Connection
	constructor: (@c, @privateKey) ->
		# Setup a new connection
		console.log "Server Started"

		fs.readFile 'data/key.pub', 'utf8', (err, data) =>
			if err
				@c.write 'Could not load public key\r\n'
				@c.end()
				return

			@c.write data
			
			# Listen to events
			@c.on 'end', @end
			@c.on 'data', @data
	
	# Called when the client disconnects from the server.
	# Optional: Pass terminate = true for the server to disconnect on the client.
	end: (terminate = false) =>
		# End the connection
		@c.end()
		console.log "Server Disconnected"
		@endFunc?(@c)

	data: (data) =>
		clearData = @privateKey.decrypt data
		console.log "Received: #{clearData}"
		@dataFunc?(data)

	
	###
		Events Associated With A Connection
	###
	# Call this function when the connection is terminated.
	onEnd: (@endFunc) =>

	onData: (@dataFunc) =>


# Export the Connection class
module.exports = Connection

