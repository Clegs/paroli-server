# users.coffee - Manages the users on the server

async = require 'async'
fs = require 'fs'

# Creates a new user on the server with the username 'name',
# password hash 'passwordHash', and 'key'.
# When done calls callback(err)
module.exports.create = (name, passwordHash, key, doneCallback) ->
	userPath = "data/users/#{name}"

	async.waterfall [
		(callback) ->
			fs.exists userPath, (exists) ->
				if exists
					doneCallback "Error: User already exists."
					callback true
				else
					callback null
		(callback) ->
			# User doesn't exist, so create it.
			fs.mkdir userPath, "0777", ->
				fs.mkdir "#{userPath}/files", "0777", ->
					callback null
		(callback) ->
			fs.writeFile "#{userPath}/password", passwordHash, 'utf8', (err) ->
				callback null
		(callback) ->
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
				###
					name - The name of the group the user is a member of.
					role - The users position inside the group.
				###
				messageDB.run """
					CREATE TABLE groups (
						name TEXT,
						role TEXT);
					"""
			messageDB.close()

			
	]
