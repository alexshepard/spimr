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
        req.session.user = User
        req.session.user_id = user.id
        # TODO: handle remember me
        res.redirect('/admin/spimes')
        return
      req.flash 'error', 'Incorrect credentials'
      res.redirect('/')
    req.flash 'error', 'Incorrect credentials'
    res.redirect('/')
  
  app.del '/sessions',  (req, res) ->
    req.session.regenerate (err) ->
      res.redirect '/'

  app.get '/sessions', (req, res) ->
    if req.body._method == 'delete'
      req.sessions.regenerate (err) ->
        res.redirect('/')
        return
    req.flash 'error', 'Unsupported method'
    res.redirect('/')
module.exports = routes