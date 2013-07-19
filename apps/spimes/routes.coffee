mongoose = require 'mongoose'

Spime = require '../../models/spime'
User = require '../../models/user'

routes = (app) ->
  
  app.namespace '/spimes', ->
  
    app.get '/mine', (req, res) ->
      app.locals.requiresLogin(req, res)
      Spime = mongoose.model('Spime')
      Spime.find({ owner: req.session.user_id}).populate('owner').exec (err, spimes) ->
        res.render "#{__dirname}/views/mine",
          title: "My Spimes"
          stylesheet: "admin"
          spimes: spimes
          info: req.flash 'info'
          error: req.flash 'error'

    app.get '/new', (req, res) ->
      app.locals.requiresLogin(req, res)
      Spime = mongoose.model('Spime')
      spime = new Spime()
      res.render "#{__dirname}/views/new",
        title: res.name
        stylesheet: "admin"
        spime: spime
        info: req.flash 'info'
        error: req.flash 'error'

    app.get '/:id', (req, res) ->
      Spime = mongoose.model('Spime')
      Spime.findOne({ _id: req.params.id }).populate('owner').exec (err, spime) ->
        res.send(500, { error: err }) if err?
        if spime?
          if spime.privacy == 'public' || spime.owner.id == req.session.user_id
            spime.checkin_url = app.locals.checkinUrlForUuid(req, spime.uuid)
            res.render "#{__dirname}/views/spime",
              title: res.name
              stylesheet: "spime"
              spime: spime
              info: req.flash 'info'
              error: req.flash 'error'
            return
          else
            req.flash 'error', 'Permission denied.'
            res.redirect '/'
            return
        res.send(404)
    
    app.get '/', (req, res) ->
      Spime = mongoose.model('Spime')
      Spime.find({ privacy: 'public'}).populate('owner').exec (err, spimes) ->
        res.send(500, { error: err}) if err?
        if spimes?
          res.render "#{__dirname}/views/public",
            title: 'Public Spimes'
            stylesheet: "spimr"
            spimes: spimes
            info: req.flash 'info'
            error: req.flash 'error'
          return
        res.send(404)
    
    app.get '/edit/:id', (req, res) ->
      app.locals.requiresLogin(req, res)
      Spime = mongoose.model('Spime')
      Spime.findById req.params.id, (err, spime) ->
        res.send(500, { error: err}) if err?
        if spime?
          if req.session.user_id != String(spime.owner)
            req.flash 'error', 'Permission denied.'
            res.redirect '/'
            return
          res.render "#{__dirname}/views/edit",
            title: res.name
            stylesheet: "admin"
            spime: spime
            info: req.flash 'info'
            error: req.flash 'error'
          return
        res.send(404)
  
    app.post '/', (req, res) ->
      app.locals.requiresLogin(req, res)
      User = mongoose.model('User')
      User.findById req.session.user_id, (err, user) ->
        res.send(500, { error: err }) if err?
        if user?
          Spime = mongoose.model('Spime')
          attributes = req.body
          spime = new Spime(attributes)
          spime.owner = user._id
          spime.save (err, saved) ->
            res.send(500, {error: err}) if err?
            req.flash 'info', 'Spime created.'
            res.redirect '/spimes/mine'
            return
  
    app.put '/:id', (req, res) ->
      app.locals.requiresLogin(req, res)
      Spime = mongoose.model('Spime')
      Spime.findById req.params.id, (err, spime) ->
        res.send(500,  { error: err}) if err?
        if spime?
          if req.session.user_id != String(spime.owner)
            req.flash 'error', 'Permission denied.'
            res.redirect '/'
            return
          
          attributes = req.body
          Spime.findByIdAndUpdate(req.params.id, { $set: attributes }).populate('owner').exec (updateErr, updatedSpime) ->
            res.send(500, { error: updateErr}) if updateErr?
            if updatedSpime?
              req.flash 'info', 'Spime edited.'
              res.redirect "/spimes/#{req.params.id}"
              return
            else
              res.send(404)
        else
          res.send(404)
  
    app.delete '/:id', (req, res) ->
      app.locals.requiresLogin(req, res)
      Spime = mongoose.model('Spime')
      Spime.findById req.params.id, (err, spime) ->
        res.send(500,  { error: err}) if err?
        if spime?
          if req.session.user_id != String(spime.owner)
            req.flash 'error', 'Permission denied.'
            res.redirect '/'
            return
          spime.remove (err, spime) ->
            res.send(500, { error: err }) if err?
            req.flash 'info', 'Spime deleted.'
            res.redirect '/spimes/mine'

    
module.exports = routes