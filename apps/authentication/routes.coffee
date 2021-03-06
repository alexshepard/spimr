User = require '../../models/user'
mongoose = require 'mongoose'


routes = (app) ->
    
  app.post '/sessions', (req, res, next) ->
    User = mongoose.model('User')
    User.findOne email: req.body.email, (err, user) ->
      if user and user.authenticate(req.body.password)
        req.session.user_id = user.id
        req.session.user_email = user.email
        req.session.is_admin = user.is_admin
        # TODO: handle remember me
        req.flash 'info', 'Welcome to Spimr, ' + req.body.email
        res.redirect('/')
        return
      else
        return next(new Error('Incorrect credentials. ' +
          '<a href="/account/forgot">Forgot Password?</a>'))

  app.del '/sessions',  (req, res, next) ->
    req.session.regenerate (err) ->
      return next(err) if err?
      req.flash 'info', 'You have been logged out'
      res.redirect '/'

    
module.exports = routes