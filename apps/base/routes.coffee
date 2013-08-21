mongoose = require 'mongoose'
Spime = require '../../models/spime'

routes = (app) ->

  app.get '/', (req, res, next) ->
    res.render "#{__dirname}/views/base",
      title: 'Home'
      stylesheet: 'about'
      info: req.flash 'info'
      error: req.flash 'error'

  app.get '/about', (req, res, next) ->
    res.render "#{__dirname}/views/about",
      title: 'About'
      stylesheet: 'about'
      info: req.flash 'info'
      error: req.flash 'error'


module.exports = routes