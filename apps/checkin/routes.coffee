mongoose = require 'mongoose'
Spime = require '../../models/spime'

routes = (app) ->

  app.namespace '/checkin', ->
    
    app.get '/:uuid', (req, res) ->
      console.log('in checkin')
      Spime = mongoose.model('Spime')
      console.log('uuid is ' + req.params.uuid)
      Spime.findOne uuid: req.params.uuid, (err, spime) ->
          res.send(500, { error: err}) if err?
          if spime?
            console.log('found spime: ' + spime)
            res.send(200)
            return
          res.send(404)
      
module.exports = routes