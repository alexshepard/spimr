mongoose = require 'mongoose'
Spime = require '../../models/spime'
User = require '../../models/user'

routes = (app) ->

  # protected CRUD methods for spimes are in /admin/spimes
  
  app.namespace '/spimes', ->
    
    app.get '/:id', (req, res) ->
      Spime = mongoose.model('Spime')
      Spime.findOne({ _id: req.params.id }).populate('owner').exec (err, spime) ->
      #Spime.find({ id: req.params.id }).populate('owner').exec (err, spime) ->
        res.send(500, { error: err }) if err?
        if spime?
          if spime.privacy == 'public' || spime.owner.id == req.session.user_id
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
      res.redirect '/'
      return
      
module.exports = routes