mongoose = require 'mongoose'
Spime = require '../../models/spime'

routes = (app) ->

  app.namespace '/checkin', ->
    
    app.get '/:uuid', (req, res, next) ->
      Spime = mongoose.model('Spime')
      Spime.findOne uuid: req.params.uuid, (err, spime) ->
        return next(err) if err?
        if spime?
          res.render "#{__dirname}/views/sightings/new",
            title: "Add Sighting"
            stylesheet: "sighting"
            spime: spime
            info: req.flash 'info'
            error: req.flash 'error'
          return
        res.send(404)
        
    app.post '/', (req, res, next) ->
      Spime = mongoose.model('Spime')
      Spime
        .findOne({ _id: req.body.spime })
        .populate('owner')
        .exec (err, spime) ->
          return next(err) if err?
          if spime?
            SpimeSighting = mongoose.model('SpimeSighting')
            attributes = req.body
            sighting = new SpimeSighting(attributes)
            sighting.save (err, saved) ->
              return next(err) if err?
              spime.set('last_sighting', sighting._id)
              spime.save (err, save) ->
                return next(err) if err?
                req.flash 'info', 'Sighting recorded, thank you!'
                if spime.privacy == 'public' || 
                        (req.session.user_id && req.session.user_id == spime.owner._id)
                  res.redirect "/spimes/#{spime._id}"
                else
                  res.redirect '/'
                return

      
module.exports = routes