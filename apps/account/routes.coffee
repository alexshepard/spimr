User = require '../../models/user'
mongoose = require 'mongoose'

routes = (app) ->

  app.namespace '/account', ->

    app.get '/new', (req, res) ->
      res.render "#{__dirname}/views/account/new",
        title: 'New Account'
        stylesheet: 'account'
        info: req.flash 'info'
        error: req.flash 'error'
    
    app.post '/', (req, res) ->
      User = mongoose.model('User')
      attributes = req.body
      user = new User(attributes)
      user.save (err, saved) ->
        if err?
          if err.code == 11000
            req.flash 'error', 'Email address already exists.'
          else
            req.flash 'error', 'Account creation failed :' + err.message
          res.redirect('/account/new')
          return
        req.session.user_id = user.id
        req.flash 'info', 'Account created.'
        res.redirect '/'

module.exports = routes