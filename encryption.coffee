###
# encryption.coffee - In charge of encrypting and decrypting the data
# being sent to the user and being stored on the disk.
###

crypto = require 'crypto'

class Encryption
	constructor: (@key, @privateKey) ->
		
	encode: (data) =>
		cipher = crypto.createCipher 'aes256', @key
		buf1 = new Buffer cipher.update(data), 'binary'
		buf2 = new Buffer cipher.final(), 'binary'
		Buffer.concat [buf1, buf2]
	
	decode: (data) =>
		decipher = crypto.createDecipher 'aes256', @key
		"#{decipher.update data}#{decipher.final()}"
	
	encObj: (obj) =>
		@encode JSON.stringify obj
	
	decObj: (data) =>
		JSON.parse @decode data

module.exports = Encryption

