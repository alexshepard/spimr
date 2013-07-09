Spime = require '../../models/spime'

mongoose = require 'mongoose'

routes = (app) ->
  
  app.namespace '/admin', ->
    
    app.namespace '/account', ->
      
      app.get '/', (req, res) ->
        Resource = mongoose.model('User')
        Resource.findById req.session.user_id
    
    
    
    app.namespace '/spimes', ->
    
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
          res.redirect '/admin/spimes'
      
      app.put '/:id', (req, res) ->
        Spime = mongoose.model('Spime')
        attributes = req.body
        Spime.findByIdAndUpdate req.params.id, {$set: attributes }, (err, spime) ->
          res.send(500,  { erro: err}) if err?
          if spime?
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
          if spime?
            res.redirect '/admin/spimes'
          res.send(404)
      
module.exports = routes