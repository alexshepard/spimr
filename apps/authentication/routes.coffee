User = require '../../models/user'
mongoose = require 'mongoose'

routes = (app) ->

  app.get '/login', (req, res) ->
    res.render "#{__dirname}/views/login",
      title: 'Login'
      stylesheet: 'login'
      info: req.flash 'info'
      error: req.flash 'error'
    
  app.post '/sessions', (req, res) ->
    User = mongoose.model('User')
    User.findOne email: req.body.email, (err, user) ->
      if user and user.authenticate(req.body.password)
        req.session.user_id = user.id
        # TODO: handle remember me
        res.redirect('/admin/spimes')
        return
      req.flash 'error', 'Incorrect credentials'
      res.redirect('/login')
  
  app.del '/sessions',  (req, res) ->
    req.sessions.regenerate (err) ->
      req.flash 'info', 'You have been logged out.'
      res.redirect '/login'

module.exports = routes