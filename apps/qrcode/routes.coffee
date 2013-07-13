mongoose = require 'mongoose'
Spime = require '../../models/spime'

routes = (app) ->

  app.namespace '/qrcode', ->
    
    app.get '/:id', (req, res) ->
      Spime = mongoose.model('Spime')
      Spime.findById req.params.id, (err, spime) ->
        res.send(500, { error: err}) if err?
        if spime?
          # construct checkin url
          port = req.app.settings.port;
          port_section = ''
          if ('development' == app.get('env') and (port != 80 and port != 443))
            port_section = ":#{port}"        
          checkin_url = "#{req.protocol}://#{req.host}#{port_section}/checkin/#{spime.uuid}"

          res.render "#{__dirname}/views/qrcode",
            title: res.name
            checkin_url: checkin_url
            info: req.flash 'info'
            error: req.flash 'error'        
      
module.exports = routes