# Admin interface for configuring the server.

fs = require 'fs'
async = require 'async'
crypto = require 'crypto'
ursa = require 'ursa'
sqlite3 = require 'sqlite3'
ursa = require 'ursa'
users = require './users'

# getLine
# -------
# Get the next line from the console and call 'callback' with the line
# as the argument.  
# `callback(line)` - Callback with the text that was input after it has
# been trimmed.
getLine = (callback) ->
	process.stdin.resume()
	process.stdin.setEncoding 'utf8'
	process.stdin.once 'data', (line) ->
		process.stdin.pause()
		line = line.trim()
		callback(line)

# printUsage
# ----------
# Prints the list of commands that can be sent to the admin interface.
printUsage = ->
	console.log """
		Usage: admin.js command [parameters]

		Available Commands:
		adduser\t\tAdds a user to the server.
		       \t\tUsage: adduser username
		removeuser\tRemoves a user from the server.
		          \tUsage: removeuser username
		"""

# Command Functions
# =================

# addUser
# -------
# Called when the user runs the admin command. Looks for the username as
# the next argument on the command line.  
# Usage: `admin.js adduser name`
addUser = ->
	passwordHash = null

	if process.argv.length < 4
		console.error "Need to specify a username."
		printUsage()
		process.exit 1
	
	# Note: Users should always be case insensitive.
	userName = process.argv[3].toLowerCase().trim()
	
	async.waterfall [
		(callback) ->
			# Check if the user already exists
			users.exists userName, (exists) ->
				if exists
					console.error "User already exists."
					process.exit 2
				else
					callback null
		(callback) ->
			process.stdout.write "Password: "
			getLine (password) ->
				callback null, password
		(password, callback) ->
			hash = crypto.createHash "sha512"
			hash.update "#{userName}#{password}", 'utf8'
			passwordHash = hash.digest 'base64'
			
			# Create the password
			key = crypto.randomBytes 32
			keyCipher = crypto.createCipher "aes256", password
			keyEnc = keyCipher.update key, 'binary', 'base64'
			keyEnc += keyCipher.final 'base64'

			# Create Pub / Private Keys
			pubpriv = ursa.generatePrivateKey 4096, 65537
			privateKey = pubpriv.toPrivatePem()
			publicKey = pubpriv.toPublicPem()
			keyCipher = crypto.createCipher 'aes256', key
			privateKeyEnc = "#{keyCipher.update privateKey, 'utf8', 'base64'}#{keyCipher.final 'base64'}"

			users.create userName, passwordHash, keyEnc, privateKeyEnc, publicKey,
				(err) ->
					callback err
	]

# removeUser
# ----------
# Removes a user and deletes all their data from the system.  
# Usage: `admin.js removeuser name`
removeUser = ->
	# Make sure a username was supplied.
	if process.argv.length < 4
		console.error "Need to specify a username."
		printUsage()
		process.exit 1
	
	userName = process.argv[3]

	users.remove userName, (err) ->
		if err
			console.error """
				The user could not be removed. Is it possible the user
				does not exist?"""

# addGroup
# --------
# Adds a user to the the specified group.  
# Usage: `admin.js addgroup user group role`
addGroup = ->
	if process.argv.length < 6
		console.error "Need to specify a username, group name, and role."
		printUsage()
		process.exit 1

	userName = process.argv[3]
	group = process.argv[4]
	role = process.argv[5]

	userPath = "data/users/#{userName}"

	messageDB = new sqlite3 "#{userPath}/messages.db"

# Script
# ======

# Check for the right number of arguments
if process.argv.length < 3
	console.error "Not enough arguments."
	printUsage()
	process.exit 1

# Check to make sure the program is installed
unless fs.existsSync 'data'
	console.error 'Program not installed. Please run ./install.js'
	process.exit 2

# Check the command and run its functions
switch process.argv[2]
	when "adduser" then addUser()
	when "removeuser" then removeUser()
	when "help" then printUsage()
	else
		printUsage()
		process.exit 1


