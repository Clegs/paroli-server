###
  admin.coffee - Admin interface for configuring the server.
###

fs = require 'fs'
async = require 'async'
crypto = require 'crypto'
ursa = require 'ursa'
sqlite3 = require 'sqlite3'
ursa = require 'ursa'
users = require './users'

# Get the next line from the console and call 'callback' with the line
# as the argument.
getLine = (callback) ->
	process.stdin.resume()
	process.stdin.setEncoding 'utf8'
	process.stdin.once 'data', (line) ->
		process.stdin.pause()
		line = line.trim()
		callback(line)

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
addUser = ->
	passwordHash = null

	if process.argv.length < 4
		console.error "Need to specify a username."
		printUsage()
		process.exit 1
	
	userName = process.argv[3].toLowerCase().trim()
	userPath = "data/users/#{userName}"

	# Check if the user already exists
	if fs.existsSync userPath
		console.error "User already exists."
		process.exit 2
	
	async.waterfall [
		(callback) ->
			process.stdout.write "Password: "
			callback null
		(callback) ->
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

removeUser = ->
	if process.argv.length < 4
		console.error "Need to specify a username."
		printUsage()
		process.exit 1
	
	userName = process.argv[3]
	
	users.remove userName, (err) ->

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


