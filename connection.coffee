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
					@enc = new Encryption @key, @privateKey
					callback null

				@c.write publicKey
			(callback) =>
				# Setup variables
				@loggedin = false
				@user = "[anonymous]"

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
		@processCommand @enc.decObj data

		@dataFunc?(data)
	
	processCommand: (cmd, callback) =>
		unless cmd.command?
			callback {message: "No command given."}
			return

		response = {}

		# Functions called to process commands.
		# Each function should add the output to be given to the client in the
		# 'response' variable. When the function has completed it should call
		# 'callback()' to send 'response' to the client.
		cmdLogin = (callback) =>
			# Check to make sure the right parameters are there.
			if cmd.user? and cmd.password?
				fs.readFile "data/users/#{cmd.user}/password", (err, data) =>
					if err or "#{cmd.password}" isnt "#{data}" or @loggedin
						response.success = false
						console.log "User '#{cmd.user}' tried to log in but failed."
					else
						response.success = true
						console.log "User '#{cmd.user}' has successfully logged in."

						@user = cmd.user
						@loggedin = true

					callback()

		cmdLogout = (callback) =>
			if @loggedin
				response.success = true
				response.message = "Successfully logged out."
				console.log "User '#{@user}' has logged out."
				# Clear variables
				@user = "[anonymous]"
				@loggedin = false
			else
				response.success = false
				response.message = "You are already logged out."

			callback()
		
		async.waterfall [
			(callback) =>
				switch cmd.command
					when "login" then cmdLogin => callback null
					when "logout" then cmdLogout => callback null
					else
						response.message = "No command given."
						callback null
			(callback) =>
				@c.write @enc.encObj response
				callback null
		]
	
	###
		Events Associated With A Connection
	###
	# Call this function when the connection is terminated.
	onEnd: (@endFunc) =>

	onData: (@dataFunc) =>


# Export the Connection class
module.exports = Connection

