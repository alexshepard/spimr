User = require '../../models/user'
mongoose = require 'mongoose'


routes = (app) ->
    
  app.post '/sessions', (req, res, next) ->
    if req.body.submitButton == 'signin'
      User = mongoose.model('User')
      User.findOne email: req.body.email, (err, user) ->
        if user and user.authenticate(req.body.password)
          req.session.user_id = user.id
          req.session.user_email = user.email
          # TODO: handle remember me
          req.flash 'info', 'Welcome to Spimr, ' + req.body.email
          res.redirect('/')
          return
        req.flash 'error', 'Incorrect credentials. <a href="/account/forgot">Forgot Password?</a>'
        res.redirect('/')
    else
      User = mongoose.model('User')
      attributes = req.body
      user = new User(attributes)
      user.save (err, saved) ->
        if err?
          if err.code == 11000
            req.flash 'error', 'Email address already exists.'
            res.redirect('/')
            return
          else
            return next(err)
        req.session.user_id = user.id
        req.session.user_email = user.email
        req.flash 'info', 'Account created.'
        res.redirect '/'

  app.del '/sessions',  (req, res, next) ->
    req.session.regenerate (err) ->
      return next(err) if err?
      req.flash 'info', 'You have been logged out'
      res.redirect '/'

    
module.exports = routes