mongoose = require 'mongoose'
Spime = require '../../models/spime'

routes = (app) ->

  app.namespace '/checkin', ->
    
    app.get '/:uuid', (req, res) ->
      Spime = mongoose.model('Spime')
      Spime.findOne uuid: req.params.uuid, (err, spime) ->
          res.send(500, { error: err}) if err?
          if spime?
            res.render "#{__dirname}/views/sightings/new",
              title: res.name
              stylesheet: "sighting"
              spime: spime
              info: req.flash 'info'
              error: req.flash 'error'
            return
          res.send(404)
        
    app.post '/', (req, res) ->
      Spime = mongoose.model('Spime')
      Spime.find({ _id: req.body.spime }).populate('owner').populate('last_sighting').exec (err, spime) ->
        res.send(500, { error: err}) if err?
        if spime?
          SpimeSighting = mongoose.model('SpimeSighting')
          attributes = req.body
          sighting = new SpimeSighting(attributes)
          sighting.save (err, saved) ->
            res.send(500, {error: err}) if err?
            Spime.update({ _id: req.body.spime } , {$set: { 'last_sighting' : sighting }}, (updateErr, updateSaved) ->
              res.send(500, {error: updateErr}) if updateErr?
              req.flash 'info', 'Sighting recorded, thank you!'
              if spime.privacy == 'public' || 
                      (req.session.user_id && req.session.user_id == spime.owner._id)
                res.redirect "/spimes/#{spime._id}"
              else
                res.redirect '/'
              return
            )

      
module.exports = routes