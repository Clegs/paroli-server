# Manages the communication between the client and server.

fs = require 'fs'
async = require 'async'
crypto = require 'crypto'
Encryption = require './encryption'

# Connection
# ----------
# Contains data about a given connection. Should be instanciated once for every
# open connection to the server.  
# The `Connection` class automatically maintains state and uses the `Encryption`
# class to automatically encrypt and decrypt data.
class Connection
    # constructor
    # -----------
    # Setups the `Connection` class with with the current connection and key.
    # `@c` - The connection object given by the server.
    # `@privateKey` - An instantiated private key from `ursa.createPrivateKey`
    constructor: (@c, @privateKey) ->
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

    # end
    # ---
    # Called when the client disconnects from the server.
    # `terminate` - Optional: Pass `terminate = true` for the server to
    # disconnect on the client.
    end: (terminate = false) =>
        @c.end()
        console.log "Connection Disconnected"
        @endFunc?(@c)

    # data
    # ----
    # Called when the client sends data to the server.
    # `data` - The encrypted data that is sent to the server.
    data: (data) =>
        decodedData = @end.decObj data
        @processCommand decodedData

        @dataFunc? decodedData

    # processCommand
    # --------------
    # Takes the unencrypted data from the client as an object and processes
    # it.
    # `cmd` - The data as an object from the client.
    # `commandCallback(err)` - Called when the program is done running.
    # `err` - The error message. `null` if no error occured.
    processCommand: (cmd, commandCallback) =>
        unless cmd.command?
            commandCallback {message: "No command given."}
    return

        response = {}

        # Functions called to process commands.
        # =====================================
        # Each function should add the output to be given to the client in the
        # 'response' variable. When the function has completed it should call
        # 'callback()' to send 'response' to the client.

        # cmdLogin
        # --------
        # Called when the user is trying to log in to the server.
        # `callback()` - Called when the login command has been successfully
        # processed.
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

        # cmdLogout
        # ---------
        # Called when the user is trying to log out of the server.
        # `callback()` - Called wehn the logout command has been successfully
        # processed.
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
                    when "login" then cmdLogin =>
                        callback null
                    when "logout" then cmdLogout =>
                        callback null
                    else
                        response.message = "No command given."
                        callback null
            (callback) =>
                @c.write @enc.encObj response
                callback null
        ], commandCallback

    # Event Listeners
    # ===============
    # The following functions setup even listeners.
    # Do not make listeners directly on the connection!

    # onEnd
    # -----
    # Set up an event listener to be called when the connection is terminated.
    # `@endFunc(con)` - The function to be called when the connection is lost.
    # `con` - The connection that was just ended.
    onEnd: (@endFunc) =>

        # onData
        # ------
        # Set up an event listener to be called when data is sent from the client.
        # `@dataFunc(data)` - The function to be called when data is received.
        # `data` - The unencrypted object that represents the data.
    onData: (@dataFunc) =>


# Export the Connection class
module.exports = Connection

