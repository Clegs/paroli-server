###
  admin.coffee - Admin interface for configuring the server.
###

fs = require 'fs'
async = require 'async'
crypto = require 'crypto'
ursa = require 'ursa'
sqlite3 = require 'sqlite3'
ursa = require 'ursa'

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
			
			# Create files
			fs.mkdirSync userPath
			fs.mkdirSync "#{userPath}/files"
			fs.writeFileSync "#{userPath}/password", passwordHash, 'utf8'

			# Create messages database
			###
				Table: messages
				id - The identification of the message
				from - The user who sent the message
				sent - The time that the message was sent
				received - The time the message was received
				read - 1 if message is read, 0 otherwise
				message - The encrypted message
				attachments - Files attached to the message
			###
			messageDB = new sqlite3.Database "#{userPath}/messages.db"
			messageDB.serialize ->
				messageDB.run """
					CREATE TABLE received (
							id INTEGER PRIMARY KEY,
							`from` TEXT
							sent REAL,
							received REAL,
							read INTEGER,
							message BLOB,
							attachments BLOB);
					"""
				messageDB.run """
					CREATE TABLE sent (
							id INTEGER PRIMARY KEY,
							`to` TEXT,
							sent REAL,
							received REAL,
							read INTEGER,
							message BLOB,
							attachments BLOB);

					"""
			messageDB.close()
			
			# Create the password
			key = crypto.randomBytes 32
			keyCipher = crypto.createCipher "aes256", password
			keyEnc = keyCipher.update key, 'binary', 'base64'
			keyEnc += keyCipher.final 'base64'
			fs.writeFileSync "#{userPath}/key", keyEnc, 'utf8'

			# Create Pub / Private Keys
			pubpriv = ursa.generatePrivateKey 4096, 65537
			privateKey = pubpriv.toPrivatePem()
			publicKey = pubpriv.toPublicPem()
			keyCipher = crypto.createCipher 'aes256', key
			privateKeyEnc = "#{keyCipher.update privateKey, 'utf8', 'base64'}#{keyCipher.final 'base64'}"
			fs.writeFileSync "#{userPath}/privateKey.pem", privateKeyEnc, 'utf8'
			fs.writeFileSync "#{userPath}/publicKey.pem", publicKey, 'utf8'

			callback null
	]

removeUser = ->
	if process.argv.length < 4
		console.error "Need to specify a username."
		printUsage()
		process.exit 1
	
	userName = process.argv[3]
	
	unless fs.existsSync "data/users/#{userName}"
		console.error "#{userName} does not exist."
		process.exit 2
	
	recursiveDelete = (dir) ->
		files = fs.readdirSync dir
		
		for file in files
			stat = fs.statSync "#{dir}/#{file}"
			if stat.isFile() then fs.unlinkSync "#{dir}/#{file}"
			else if stat.isDirectory() then recursiveDelete "#{dir}/#{file}"

		fs.rmdirSync dir
	
	recursiveDelete "data/users/#{userName}"

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


