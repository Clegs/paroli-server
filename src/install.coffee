# This program will setup the data directories for the server.
# Please remove the 'data' folder if it already exists.

fs = require 'fs'
crypto = require 'crypto'
ursa = require 'ursa'

# Check to make sure there is no data directory.
# If it exists than exit immediatly.
if fs.existsSync 'data'
    console.log 'The \'data\' directory already exists.'
    process.exit 1

# Create the following directories in the order listed.
directories = [
    'data'
    'data/users'
    'data/groups'
]

for dir in directories
    console.log "Creating: #{dir}"
    fs.mkdirSync dir

console.log "Generating Keys"
key = ursa.generatePrivateKey 4096, 65537
privateKey = key.toPrivatePem()
publicKey = key.toPublicPem()
console.log "Keys generated"

# Write the keys to files
fs.writeFile "data/key", privateKey, (err) ->
    console.error "File could not be written. #{err}" if err
fs.writeFile "data/key.pub", publicKey, (err) ->
    console.error "File could not be written. #{err}" if err
