User = require '../../models/user'
mongoose = require 'mongoose'
crypto = require 'crypto'
postmark = require('postmark')(process.env.POSTMARK_API_KEY)

routes = (app) ->
        
  app.namespace '/account', ->

    app.get '/forgot', (req, res) ->
      res.render "#{__dirname}/views/forgot",
        title: "Forgot Password"
        stylesheet: "forgot"
        info: req.flash 'info'
        error: req.flash 'error'
      return
    
    app.get '/edit/:email', (req, res) ->
      User = mongoose.model('User')
      User.findOne ({ email: req.params.email }), (err, user) ->
        (res.send(500, {error: err }); return) if err?
        (res.send(404); return) if !user?
        if String(user._id) != String(req.session.user_id)
          req.flash 'error', 'Permission denied.'
          res.redirect '/'
          return
        res.render "#{__dirname}/views/edit",
          title: "Edit My Account"
          stylesheet: "account"
          user: user
          info: req.flash 'info'
          error: req.flash 'error'
        return
    
    app.put '/edit', (req, res) ->
      User = mongoose.model('User')
      User.findOne ({ _id: req.body._user_id }), (err, user) ->
        (res.send(500, {error: err }); return) if err?
        (res.send(404); return) if !user?
        if String(user._id) != String(req.session.user_id)
          req.flash 'error', 'Permission denied.'
          res.redirect '/'
          return
        attributes = req.body
        delete attributes._user_id

        user.update { $set: attributes }, (err, update) ->
          if err?
            if err.code? and err.code == 11001
              req.flash 'error', 'Nickname already taken.'
              res.redirect '/account/me'
              return
            else
              res.send(500)
              return
          (res.send(404); return) if !user?
          req.flash 'info', 'User account updated.'
          res.redirect '/account/me'
          return
    
    app.delete '/me', (req, res) ->
      app.locals.requiresLogin(req, res)
      User = mongoose.model('User')
      User.findById req.session.user_id, (err, user) ->
        (res.send(500, { error: err }); return;) if err?
        (res.send(404); return;) unless user?
        user.remove (err, status) ->
          (res.send(500, { error: err }); return;) if err?
          req.session.regenerate (err) ->
            (res.send(500, { error: err }); return;) if err?
            req.flash 'info', 'Account deleted.'
            res.redirect '/'
          
          
    app.get '/me', (req, res) ->
      User = mongoose.model('User')
      app.locals.requiresLogin(req, res)
      User.findById req.session.user_id, (err, user) ->
        res.send(500, { error: err }) if err?
        if user?
          res.render "#{__dirname}/views/account",
            title: "About Me"
            stylesheet: "account"
            user: user
            info: req.flash 'info'
            error: req.flash 'error'
          return
        else
          res.send(404)
          return

    app.get '/:id', (req, res) ->
      User = mongoose.model('User')
      User.findOne { _id: req.params.id }, (err, user) ->
        res.send(500, { error: err }) if err?
        if user?
          if req.session && req.session.user_id && req.session.user_id == user._id
            res.redirect '/account/me'
            return
          else
            res.render "#{__dirname}/views/account",
              title: "About #{user.nickname}"
              stylesheet: "account"
              user: user
              info: req.flash 'info'
              error: req.flash 'error'
            return
        else
          res.send(404)
          return
                
      app.post '/forgot', (req, res) ->
        User = mongoose.model('User')
        User.findOne { email: req.body.email }, (err, user) ->
          if err?
            req.flash 'error', 'Unable to send password reset email: ' + err.message
            res.redirect '/'
            return
          if user?
            if user.reset_password_timestamp?
              if (new Date().getTime() - user.reset_password_timestamp.getTime()) < (60 * 1000)
                req.flash 'error', 'Please wait a minute to request a new password.'
                res.redirect '/'
                return
            crypto.randomBytes 24, (ex, buf) ->
              attributes = {
                reset_password_token: buf.toString 'hex'
                reset_password_timestamp: new Date
              }
              User.findOneAndUpdate { email: req.body.email }, { $set: attributes }, (err, update) ->
                res.send(500, { error: err}) if err?
                if update?
                  # construct and send email
                  resetUrl = app.locals.baseUrl(req) + '/account/reset/' + req.body.email + '/' + update.reset_password_token
                  bodyText = 'Someone has requested to your password on spimr.com. If this was you, please click this link: ' + resetUrl + "\n\n If it wasn\'t you, please ignore this email."
                  email = {
                      From: "Spimr Support <spimr@spimr.com>"
                      To: req.body.email
                      Subject: "Reset Password"
                      TextBody: bodyText
                  } 
                  postmark.send email, (err, success) ->
                    if err?
                      req.flash 'error', 'Unable to send password reset email: ' + err.message
                      res.redirect '/'
                      return
                    else
                      req.flash 'info', 'Email sent.'
                      res.redirect '/'
                      return
                else
                  res.send(404)
                  return

            
            
          else
            req.flash 'error', 'No such user'
            res.redirect '/'
            return
            

      app.put '/password', (req, res) ->
        if req.body.password != req.body.confirm
          req.flash 'error', 'Passwords don\'t match.'
          res.redirect '/account/reset/' + req.body._email + '/' + req.body._token
          return
        User = mongoose.model('User')
        attributes = {
          password: req.body.password,
          reset_password_token: null,
          reset_password_timestamp: null 
        }
        
        User.findOne { email: req.body._email }, (err, user) ->
          if err?
            req.flash 'error', 'Error : ' + err.message
            res.redirect '/'
            return
          if user?
            if user.reset_password_token != req.body._token
              req.flash 'error', 'Permission denied'
              res.redirect '/'
              return
              
            if (new Date().getTime() - user.reset_password_timestamp.getTime()) > (60 * 60 * 2 * 1000)
              req.flash 'error', 'Password reset has expired.'
              res.redirect '/'
              return
              
            user.update { $set: attributes }, (err, update) ->
              if err?
                req.flash 'error', 'Error saving new password'
                res.redirect '/'
                return
              if update?
                req.flash 'info', 'Password updated.'
                res.redirect '/'
                return      
              req.flash 'error', 'Error updating'
              res.redirect '/'
              return
              
          else
            req.flash 'error', 'Error: user not found'
            res.redirect '/'
            return

      app.get '/reset/:email/:token', (req, res) ->
        User = mongoose.model('User')
        User.findOne { email: req.params.email }, (err, user) ->
          if err?
            req.flash 'error', 'Error :('
            res.redirect '/'
            return
          if user?
            if user.reset_password_token == req.params.token
              if (new Date().getTime() - user.reset_password_timestamp.getTime()) > (60 * 60 * 2 * 1000)
                req.flash 'error', 'Password reset has expired.'
                res.redirect '/'
                return
              else
                res.render "#{__dirname}/views/reset",
                  title: "Reset Password"
                  stylesheet: "forgot"
                  user: user
                  info: req.flash 'info'
                  error: req.flash 'error'
                return
            else
              req.flash 'error', 'Password reset token invalid.'
              res.redirect '/'
              return
          else
            req.flash 'error', 'Error finding that email.'
            res.redirect '/'
            return
        

        

 
module.exports = routes
