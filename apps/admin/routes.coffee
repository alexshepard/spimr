Spime = require '../../models/spime'

mongoose = require 'mongoose'

routes = (app) ->
  
  app.namespace '/admin', ->
    
    app.namespace '/spimes', ->
    
      app.get '/:id', (req, res) ->
        Resource = mongoose.model('Spime')
        Resource.findById req.params.id, (err, resource) ->
          res.send(500, { error: err}) if err?
          if resource?
            res.render "#{__dirname}/views/spimes/one",
              title: res.name
              stylesheet: "admin"
              spime: resource
            return
          res.send(404)
      
      app.get '/', (req, res) ->
        Resource = mongoose.model('Spime')
        
        Resource.find {}, (err, collection) ->
          res.render "#{__dirname}/views/spimes/mine",
            title: "My Spimes"
            stylesheet: "admin"
            spimes: collection
      
      
      app.post '/', (req, res) ->
        Resource = mongoose.model('Spime')
        attributes = req.body
        r = new Resource(attributes)
        r.save (err, resource) ->
          res.send(500, {error: err}) if err?
          res.redirect '/admin/spimes'
      
      
      
module.exports = routes