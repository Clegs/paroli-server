# users.coffee - Manages the users on the server

class Users
	
	# online - Returns true if user online, false otherwise.
	online: (username) ->
		return false
	
	# login - Logs a user in with the given username and password hash.
	# Returns the user online ID if success. -1 otherwise.
	login: (username, password) ->
		return -1

module.exports = new Users

