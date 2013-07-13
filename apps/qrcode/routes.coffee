mongoose = require 'mongoose'

routes = (app) ->

  app.namespace '/qrcode', ->
    
    app.get '/:uuid', (req, res) ->
      port = req.app.settings.port;
      port_section = '';
      if (port != 80 && port != 443)
        port_section = ":#{port}"        
      checkin_url = "#{req.protocol}://#{req.host}#{port_section}/checkin/#{req.params.uuid}"

      res.render "#{__dirname}/views/qrcode",
        title: res.name
        checkin_url: checkin_url
        uuid: req.params.uuid
        info: req.flash 'info'
        error: req.flash 'error'
      
module.exports = routes