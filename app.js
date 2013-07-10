
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
User = require('./models/user.coffee');

var app = express();

var sessionSecret = "asdlkfjsdlkjoiwdfjoiewjfewsd";
var redis;

if (process.env.REDISTOGO_URL) {
  // Heroku redistogo connection
  rtg   = require('url').parse(process.env.REDISTOGO_URL)
  redis = require('redis').createClient(rtg.port, rtg.hostname)
  redis.auth(rtg.auth.split(':')[1]); // auth 1st part is username and 2nd is password separated by ":"
} else {
  // localhost
  redis = require("redis").createClient();
}

// all environments
app.set('port', process.env.PORT || 3000);
app.set('views', __dirname + '/views');
app.set('view engine', 'jade');
app.set('storage-uri', process.env.MONGOHQ_URL || process.env.MONGOLAB_URI || 'mongodb://localhost/spimr')
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

app.use(function(req, res, next){
  User = mongoose.model('User')
  User.findOne({ _id: req.session.user_id }, function(err, user) {
    res.locals.user = user
  });
  next();
});

app.use(app.router);
app.use(express.static(path.join(__dirname, 'public')));

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}

// Global helpers
require('./apps/helpers')(app);

// Routes
require('./apps/base/routes.coffee')(app);
require('./apps/admin/routes.coffee')(app);
require('./apps/authentication/routes.coffee')(app);
require('./apps/account/routes.coffee')(app);

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
