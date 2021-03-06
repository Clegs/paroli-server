# Main program for running the Paroli Server

fs = require 'fs'

config = require './configloader'
Server = require './server'
server = new Server()

# Do some error checking.
if not config
    console.error 'Error loading config file. Shutting down.'
    process.exit 1

if not server
    console.error 'Error loading server module. Shutting down.'
    process.exit 2

# Make sure there is a data directory.
# If not, th eprogram hasn't been installed
if not fs.existsSync 'data'
    console.error 'Program not installed. Please run ./install.js'
    process.exit 3

console.log "Starting: #{ config.name }"
server.start config

