
/**
 * Module dependencies.
 */

require('coffee-script')

var express = require('express')
  , routes = require('./routes')
  , flash = require('connect-flash')
  , http = require('http')
  , RedisStore = require('connect-redis')(express)
  , mongoose = require('mongoose')
  , path = require('path');

require('express-namespace');

var app = express();

var sessionSecret = "asdlkfjsdlkjoiwdfjoiewjfewsd";

// all environments
app.set('port', process.env.PORT || 3000);
app.set('views', __dirname + '/views');
app.set('view engine', 'jade');
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(express.cookieParser());
app.use(express.session({
  secret: "asdlkfjsdlkjoiwdfjoiewjfewsd",
  store: new RedisStore
}));
app.use(flash());
app.use(app.router);
app.use(express.static(path.join(__dirname, 'public')));
app.set('storage-uri', process.env.MONGOHQ_URL || process.env.MONGOLAB_URI || 'mongodb://localhost/spimr')

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}

// Global helpers
require('./apps/helpers')(app);

// Routes
app.get('/', routes.index);
require('./apps/admin/routes.coffee')(app);
require('./apps/authentication/routes.coffee')(app);

var err;
mongoose.connect(app.get('storage-uri'), { db: {save: true }}, (err), function() {
  if (err) {
    console.log("Mongoose - connection error: " + err);
    return;
  }
  console.log("Mongoose - connection OK");
});

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
