/*jslint node: true */
/*jslint es5: true */
/*jslint indent: 2 */
/*jslint nomen: true */

/**
 * Module dependencies.
 */

"use strict";

if (process.env.NODETIME_ACCOUNT_KEY) {
  require('nodetime').profile({
    accountKey: process.env.NODETIME_ACCOUNT_KEY,
    appName: 'Spimr'
  });
}

require('coffee-script');

var express = require('express');
var routes = require('./routes');
var flash = require('connect-flash');
var http = require('http');
var RedisStore = require('connect-redis')(express);
var mongoose = require('mongoose');
var Twitter = require('twitter');
var path = require('path');

require('express-namespace');
require('./models/user.coffee');

var app = express();

app.twit = new Twitter({
  consumer_key:         process.env.TWITTER_CONSUMER_KEY,
  consumer_secret:      process.env.TWITTER_CONSUMER_SECRET,
  access_token_key:     process.env.TWITTER_ACCESS_TOKEN_KEY,
  access_token_secret:  process.env.TWITTER_ACCESS_TOKEN_SECRET
});

var sessionSecret = "asdlkfjsdlkjoiwdfjoiewjfewsd";
var redis;

if (process.env.REDISTOGO_URL) {
  // Heroku redistogo connection
  var rtg = require('url').parse(process.env.REDISTOGO_URL);
  redis = require('redis').createClient(rtg.port, rtg.hostname);
  redis.auth(rtg.auth.split(':')[1]); // auth 1st part is username and 2nd is password separated by ":"
} else {
  // localhost
  redis = require("redis").createClient();
}

// all environments
app.set('port', process.env.PORT || 3000);
app.set('views', __dirname + '/views');
app.set('view engine', 'jade');
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(express.cookieParser());
app.use(flash());
app.use(express.session({
  secret: process.env.CLIENT_SECRET || "asdlkfjsdlkjoiwdfjoiewjfewsd",
  maxAge : Date.now() + 7200000, // 2h Session lifetime
  store: new RedisStore({client: redis})
}));

app.use(function (req, res, next) {
  res.locals.user_id = req.session.user_id;
  res.locals.user_email = req.session.user_email;
  res.locals.path = req.path;
  res.locals.google_analytics_account = process.env.GOOGLE_ANALYTICS_ACCOUNT;
  res.locals.google_maps_key = process.env.GOOGLE_MAPS_KEY;
  res.locals.moment = require('moment');
  next();
});

app.use(app.router);

app.use(function(err, req, res, next) {
    if(!err) return next();
    console.log("error!!!");
    res.send(500, 'Something broke!');
});

app.use(express.static(path.join(__dirname, 'public')));

// development only
if ('development' === app.get('env')) {
  app.use(express.errorHandler());
}

// mongo url
if ('test' === app.get('env')) {
  app.set('storage-uri', 'mongodb://localhost/spimr_test');
} else {
  app.set('storage-uri', process.env.MONGOHQ_URL || process.env.MONGOLAB_URI || 'mongodb://localhost/spimr');
}


// mongoose
var err;
mongoose.connect(app.get('storage-uri'), { db: {save: true }}, (err), function () {
  if (err) {
    console.log("Mongoose - connection error: " + err);
    return;
  }
  console.log("Mongoose - connection OK");
});

// Global helpers
require('./apps/helpers')(app);

// Routes
require('./apps/base/routes.coffee')(app);            // home page, about page, credits, etc
require('./apps/spimes/routes.coffee')(app);          // spimes
require('./apps/account/routes.coffee')(app);         // account details
require('./apps/authentication/routes.coffee')(app);  // session stuff, signin, signout
require('./apps/checkin/routes.coffee')(app);         // spime sighting handler

http.createServer(app).listen(app.get('port'), function () {
  console.log('Express server listening on port ' + app.get('port'));
});

module.exports = app;
