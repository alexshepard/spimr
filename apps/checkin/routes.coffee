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
      Spime.findOne ({ _id: req.body.spime }).populate('sightings').exec (err, spime) ->
        res.send(500, { error: err}) if err?
        if spime?
          SpimeSighting = mongoose.model('SpimeSighting')
          attributes = req.body
          sighting = new SpimeSighting(attributes)
          sighting.spime = spime._id
          spime.sightings.push sighting
          
          sighting.save (err, saved) ->
            res.send(500, {error: err}) if err?
            spime.save (spimeErr, spimeSaved) ->
              res.send(500, {error: spimeErr}) if spimeErr?
              req.flash 'info', 'Sighting recorded, thank you!'
              res.redirect '/'
              return

      
module.exports = routes