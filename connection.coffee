###
# connection.coffee - Manages the communication between the client and server.
###

class Connection
	constructor: (@c) ->
		# Setup a new connection
		console.log "Server Started"
		@c.write "User Connected\r\n"

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
		console.log "Received: #{data.toString().trim()}"
		@dataFunc?(data)

	
	###
		Events Associated With A Connection
	###
	# Call this function when the connection is terminated.
	onEnd: (@endFunc) =>

	onData: (@dataFunc) =>


# Export the Connection class
module.exports = Connection

