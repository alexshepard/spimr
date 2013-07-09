Spime = require '../../models/spime'

mongoose = require 'mongoose'

routes = (app) ->

  app.get '/', (req, res) ->
    res.render "#{__dirname}/views/base",
      title: 'Spimr'
      stylesheet: 'spimr'
      info: req.flash 'info'
      error: req.flash 'error'

module.exports = routes