mongoose = require 'mongoose'
Spime = require '../../models/spime'

routes = (app) ->

  app.get '/', (req, res) ->
    res.render "#{__dirname}/views/base",
      title: 'Spimr'
      stylesheet: 'about'
      info: req.flash 'info'
      error: req.flash 'error'

  app.get '/about', (req, res) ->
    res.render "#{__dirname}/views/about",
      title: 'About Spimr'
      stylesheet: 'about'
      info: req.flash 'info'
      error: req.flash 'error'


module.exports = routes