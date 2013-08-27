# Manages the users on the server

async = require 'async'
sqlite3 = require 'sqlite3'
fs = require 'fs'

users = {}

# getUserPath
# -----------
# `user` - The user to get the path of.  
# Returns the directory that the user's data is stored in.
getUserPath = (user) ->
    "data/users/#{user}"

# recursiveDelete
# ---------------
# Deletes the directory `dir` and all of its subdirectories and files.  
# `dir` - The directory to delete.
recursiveDelete = (dir) ->
    files = fs.readdirSync dir

    for file in files
        stat = fs.statSync "#{dir}/#{file}"
        if stat.isFile() then fs.unlinkSync "#{dir}/#{file}"
        else if stat.isDirectory() then recursiveDelete "#{dir}/#{file}"

    fs.rmdirSync dir

# exists
# ------
# Checks to see if the user already exists.  
# `name` - The username of the user.  
# `doneCallback(exists)` - Called when method is done.  
users.exists = (name, doneCallback) ->
    userPath = getUserPath name

    fs.exists userPath, (exists) ->
        doneCallback? exists

# create
# ------
# Creates a new user on the server with the username 'name',
# password hash 'passwordHash', and 'key'.
# name - Username to create.
# passwordHash - sha512 has of the password encoded in base64.
# key - Encrypted binary key.
# privateKey - Encrypted using origional password and encoded in base64.
# publicKey - Plain text public key in PEM format.
# When done calls callback(err)
users.create = (name, passwordHash, key, privateKey, publicKey, doneCallback) ->
    userPath = getUserPath name

    async.waterfall [
        (callback) ->
            users.exists name, (exists) ->
                if exists
                    callback "Error: User already exists."
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
                # `name` - The name of the group the user is a member of.
                # `role` - The users position inside the group.
                messageDB.run """
                              CREATE TABLE groups (
                              name TEXT,
                              role TEXT);
                              """
            messageDB.close()

            fs.writeFile "#{userPath}/key", key, 'utf8', (err) ->
                callback null
        (callback) ->
            fs.writeFile "#{userPath}/privateKey.pem", privateKey, 'utf8', (err) ->
                callback null
        (callback) ->
            fs.writeFile "#{userPath}/publicKey.pem", publicKey, 'utf8', (err) ->
                callback null
    ], (err) ->
        doneCallback err

# remove
# ------
# Removes a user if it exists.  
# `user` - The username to delete.  
# `doneCallback(err)` - Called when program is done.
# `err` - Any error message generated from the program. `null` if no error.
users.remove = (user, doneCallback) ->
    async.waterfall [
        (callback) ->
            users.exists user, (exists) ->
                if exists
                    callback null
                else
                    callback "User does not exist"
        (callback) ->
            recursiveDelete getUserPath user
            callback null
    ], (err) ->
        doneCallback err

module.exports = users
