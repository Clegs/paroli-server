###
# encryption.coffee - In charge of encrypting and decrypting the data
# being sent to the user and being stored on the disk.
###

class Encryption
	
	constructor: ->
		@crypto = require 'crypto'

module.exports = Encryption

