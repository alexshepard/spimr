Spime = require '../../models/spime'
User = require '../../models/user'

mongoose = require 'mongoose'

routes = (app) ->
  
  app.namespace '/admin', ->
    
    # Authentication check
    app.all '/*', (req, res, next) ->
      # TODO: could probably do a better job here
      if not (req.session.User)
        req.flash 'error', 'Please login.'
        res.redirect '/'
        return
      next()
    
    app.namespace '/account', ->
      
      app.get '/', (req, res) ->
        Resource = mongoose.model('User')
        Resource.findById req.session.user_id    
    
    app.namespace '/spimes', ->
    
      app.get '/new', (req, res) ->
        Spime = mongoose.model('Spime')
        spime = new Spime()
        res.render "#{__dirname}/views/spimes/new",
          title: res.name
          stylesheet: "admin"
          spime: spime
          info: req.flash 'info'
          error: req.flash 'error'
      
      app.get '/edit/:id', (req, res) ->
        Spime = mongoose.model('Spime')
        Spime.findById req.params.id, (err, spime) ->
          res.send(500, { error: err}) if err?
          if spime?
            res.render "#{__dirname}/views/spimes/edit",
              title: res.name
              stylesheet: "admin"
              spime: spime
              info: req.flash 'info'
              error: req.flash 'error'
            return
          res.send(404)

      app.get '/:id', (req, res) ->
        Spime = mongoose.model('Spime')
        Spime.findById req.params.id, (err, spime) ->
          res.send(500, { error: err}) if err?
          if spime?
            res.render "#{__dirname}/views/spimes/one",
              title: res.name
              stylesheet: "admin"
              spime: spime
              info: req.flash 'info'
              error: req.flash 'error'
            return
          res.send(404)
      
      app.get '/', (req, res) ->
        Spime = mongoose.model('Spime')
        Spime.find {}, (err, spimes) ->
          res.render "#{__dirname}/views/spimes/mine",
            title: "My Spimes"
            stylesheet: "admin"
            spimes: spimes
            info: req.flash 'info'
            error: req.flash 'error'

      
      app.post '/', (req, res) ->
        Spime = mongoose.model('Spime')
        attributes = req.body
        spime = new Spime(attributes)
        spime.save (err, saved) ->
          res.send(500, {error: err}) if err?
          req.flash 'info', 'Spime created,'
          res.redirect '/admin/spimes'
      
      app.put '/:id', (req, res) ->
        Spime = mongoose.model('Spime')
        attributes = req.body
        Spime.findByIdAndUpdate req.params.id, {$set: attributes }, (err, spime) ->
          res.send(500,  { erro: err}) if err?
          if spime?
            req.flash 'info', 'Spime edited,'
            res.render "#{__dirname}/views/spimes/one",
              title: res.name
              stylesheet: "admin"
              spime: spime
              info: req.flash 'info'
              error: req.flash 'error'

            return
          res.send(404)
      
      app.delete '/:id', (req, res) ->
        Spime = mongoose.model('Spime')
        Spime.findByIdAndRemove req.params.id, (err, spime) ->
          res.send(500, { error: err }) if err?
          req.flash 'info', 'Spime deleted,'
          res.redirect '/admin/spimes'
      
module.exports = routes