#!/usr/bin/env node
var express = require('express'); 
var debug = require('debug')('socket-example');
var app = express();
var mongoose = require('mongoose');

app.set('port', process.env.PORT || 3000);

//mongoose
var Schema = mongoose.Schema;
var MessagesSchema = new Schema({
	name: String,
	message: String,
	date: Date
});
mongoose.model('messages', MessagesSchema);
mongoose.connect('mongodb://localhost/socket-example');
var Messages = mongoose.model('messages');

//socket.io
var http = require('http').Server(app);
var io = require('socket.io')(http);
io.on('connection', function(socket) {

	socket.on('disconnect', function() {
		console.log('user disconnected');
	});

	socket.on('message init', function(data) {
		console.log('message init');

		Messages.find({}).limit(100).exec(function(err, data){
			socket.emit('message init', data);
    	});
	});

	socket.on('message send', function(data) {
		console.log('message send');

		data.date = Date.parse(data.date);
		var message = new Messages(data);
		message.save(function(err, message) {
			if (err) return console.error(err);
			io.emit('message send', message);
		});
	});
});

http.listen(3000, function() {
	console.log('listening on *:3000');
});