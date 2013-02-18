#!/usr/bin/env node

// start.js - Main program for running the Paroli Server

var config = require('./configloader');
var server = require('./server');

console.log('Starting: %s', config.name);

server.start(config);

