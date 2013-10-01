User = require '../../models/user'
mongoose = require 'mongoose'
crypto = require 'crypto'
postmark = require('postmark')(process.env.POSTMARK_API_KEY)

routes = (app) ->
        
  app.namespace '/people', ->

    app.get '/new', (req, res, next) ->
      res.render "#{__dirname}/views/create",
        title: "Create New Account"
        stylesheet: "create"
        info: req.flash 'info'
        error: req.flash 'error'
      return

    app.post '/new', (req, res, next) ->
      User = mongoose.model('User')
      attributes = req.body
      user = new User(attributes)
      user.save (err, saved) ->
        if err?
          if err.code == 11000
            req.flash 'error', 'Email address already exists.'
            res.redirect('/people/new')
            return
          else if err.name == 'ValidationError'
            error_string = ""
            for validation_error of err.errors
              error_string = error_string + "Invalid #{validation_error} :( "
            req.flash 'error', error_string
            res.redirect('/people/new')
            return
          else
            return next(err)
        req.session.user_id = user.id
        req.session.user_email = user.email
        req.session.is_admin = user.is_admin
        req.flash 'info', 'Account created.'
        res.redirect '/'


    app.get '/forgot', (req, res, next) ->
      res.render "#{__dirname}/views/forgot",
        title: "Forgot Password"
        stylesheet: "forgot"
        info: req.flash 'info'
        error: req.flash 'error'
      return
    
    app.get '/edit/:email', (req, res, next) ->
      User = mongoose.model('User')
      User.findOne ({ email: req.params.email }), (err, user) ->
        return next(err) if err?
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
    
    app.put '/edit', (req, res, next) ->
      if (req.body.new_password? &&
       req.body.new_password != req.body.confirm_new_password)
        req.flash 'error', "New passwords don't match."
        res.redirect '/people/me'
        return
      User = mongoose.model('User')
      User.findOne ({ _id: req.body._user_id }), (err, user) ->
        return next(err) if err?
        (res.send(404); return) if !user?
        if String(user._id) != String(req.session.user_id)
          req.flash 'error', 'Permission denied.'
          res.redirect '/'
          return
        
        if user.nickname != req.body.nickname
          user.nickname = req.body.nickname

        if req.body.new_password? && req.body.new_password.length
          if user.authenticate(req.body.old_password)
            user.set("password", req.body.new_password)
            user.set("reset_password_token", null)
            user.set("reset_password_timestamp", null)
          else
            req.flash 'error', 'Old Password Incorrect'
            res.redirect '/people/me'
            return
        
        user.save (err, saved) ->
          console.log err
          if err?
            if err.code? and err.code == 11001
              req.flash 'error', 'Nickname already taken.'
              res.redirect '/people/me'
              return
            else
              return next(err)
          if !saved?
            req.flash 'error', 'Unable to update user account.'
            res.redirect '/people/me'
            return
          req.flash 'info', 'User account updated.'
          res.redirect '/people/me'
          return
    
    app.delete '/me', (req, res, next) ->
      app.locals.requiresLogin(req, res)
      User = mongoose.model('User')
      User.findById req.session.user_id, (err, user) ->
        return next(err) if err?
        (res.send(404); return;) unless user?
        user.remove (err, status) ->
          return next(err) if err?
          req.session.regenerate (err) ->
            return next(err) if err?
            req.flash 'info', 'Account deleted.'
            res.redirect '/'
          
          
    app.get '/me', (req, res, next) ->
      User = mongoose.model('User')
      app.locals.requiresLogin(req, res)
      User.findById req.session.user_id, (err, user) ->
        return next(err) if err?
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

    app.get '/:id', (req, res, next) ->
      User = mongoose.model('User')
      User.findOne { _id: req.params.id }, (err, user) ->
        return next(err) if err?
        if user?
          if (req.session && req.session.user_id &&
           req.session.user_id == user._id)
            res.redirect '/people/me'
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
                
    app.post '/forgot', (req, res, next) ->
      User = mongoose.model('User')
      User.findOne { email: req.body.email }, (err, user) ->
        if err?
          req.flash 'error', 'Unable to send password reset email: ' +
            err.message
          res.redirect '/'
          return
        if user?
          if user.reset_password_timestamp?
            if (new Date().getTime() -
             user.reset_password_timestamp.getTime()) < (60 * 1000)
              req.flash 'error',
                'Please wait a minute to request a new password.'
              res.redirect '/'
              return
          crypto.randomBytes 24, (ex, buf) ->
            user.set("reset_password_token", buf.toString 'hex')
            user.set("reset_password_timestamp", new Date)
            user.save (err, saved) ->
              return next(err) if err?
              if saved?
                # construct and send email
                resetUrl = app.locals.baseUrl(req) + '/account/reset/' +
                  req.body.email + '/' + buf.toString 'hex'
                bodyText = 'Someone has requested to your password on ' +
                  'spimr.com. If this was you, please click this link: ' +
                  resetUrl + "\n\n If it wasn\'t you, please ignore this email."
                email = {
                  From: "Spimr Support <spimr@spimr.com>"
                  To: req.body.email
                  Subject: "Reset Password"
                  TextBody: bodyText
                }
                postmark.send email, (err, success) ->
                  if err?
                    req.flash 'error', 'Unable to send password reset ' +
                      'email: ' + err.message
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
            

    app.put '/password', (req, res, next) ->
      if req.body.password != req.body.confirm
        req.flash 'error', 'Passwords don\'t match.'
        res.redirect '/account/reset/' + req.body._email + '/' + req.body._token
        return
      User = mongoose.model('User')
      User.findOne { email: req.body._email }, (err, user) ->
        return next(err) if err?
        if user?
          if user.reset_password_token != req.body._token
            req.flash 'error', 'Permission denied'
            res.redirect '/'
            return
          if (new Date().getTime() -
           user.reset_password_timestamp.getTime()) > (60 * 60 * 2 * 1000)
            req.flash 'error', 'Password reset has expired.'
            res.redirect '/'
            return

          user.set(password, req.body.password)
          user.set(reset_password_token: null)
          user.set(reset_password_timestamp: null)
          
          user.save (err, save) ->
            if err?
              req.flash 'error', 'Error saving new password'
              res.redirect '/'
              return
            if save?
              req.flash 'info', 'Password updated.'
              res.redirect '/'
              return
        else
          req.flash 'error', 'Error: user not found'
          res.redirect '/'
          return

    app.get '/reset/:email/:token', (req, res, next) ->
      User = mongoose.model('User')
      User.findOne { email: req.params.email }, (err, user) ->
        return next(err) if err?
        if user?
          if user.reset_password_token == req.params.token
            if (new Date().getTime() -
             user.reset_password_timestamp.getTime()) > (60 * 60 * 2 * 1000)
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
