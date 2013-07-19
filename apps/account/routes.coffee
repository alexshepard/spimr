User = require '../../models/user'

mongoose = require 'mongoose'

routes = (app) ->
        
    app.namespace '/account', ->
            
      app.get '/me', (req, res) ->
        app.locals.requiresLogin(req, res)
        User = mongoose.model('User')
        User.findById req.session.user_id, (err, user) ->
          res.send(500, { error: err }) if err?
          if user?
            res.render "#{__dirname}/views/account",
              title: res.name
              stylesheet: "account"
              user: user
              info: req.flash 'info'
              error: req.flash 'error'
            return
          res.send(404)
 
module.exports = routes
