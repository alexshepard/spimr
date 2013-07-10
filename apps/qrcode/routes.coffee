mongoose = require 'mongoose'

routes = (app) ->

  app.namespace '/qrcode', ->
    
    app.get '/:uuid', (req, res) ->
      res.render "#{__dirname}/views/qrcode",
        title: res.name
        uuid: req.params.uuid
        info: req.flash 'info'
        error: req.flash 'error'
      
module.exports = routes