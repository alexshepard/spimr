User = require '../../models/user'
mongoose = require 'mongoose'
crypto = require 'crypto'
postmark = require('postmark')(process.env.POSTMARK_API_KEY)

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
          return
          
      app.get '/forgot', (req, res) ->
        res.render "#{__dirname}/views/forgot",
          title: res.name
          stylesheet: "forgot"
          info: req.flash 'info'
          error: req.flash 'error'
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
              user.update { $set: attributes }, (err, update) ->
                console.log('update is ' + update)
                res.send(500, { error: err}) if err?
                if update?
                  # construct and send email
                  # TODO: on heroku, this is showing up as:
                  # http://www.spimr.com/account/reset/valid@email.address/undefined
                  resetUrl = app.locals.baseUrl(req) + '/account/reset/' + req.body.email + '/' + update.reset_password_token
                  bodyText = 'Someone has requested to your password on spimr.com. If this was you, please click this link: ' + resetUrl + "\n\n If it wasn\'t you, please ignore this email."
                  email = {
                      From: "spimr@spimr.com"
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
                  title: res.name
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
