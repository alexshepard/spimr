Spime = require '../../models/spime'

mongoose = require 'mongoose'

routes = (app) ->

  app.get '/', (req, res) ->
    res.render "#{__dirname}/views/base",
      title: 'Spimr'
      stylesheet: 'spimr'
      info: req.flash 'info'
      error: req.flash 'error'

  app.get '/about', (req, res) ->
    res.render "#{__dirname}/views/about",
      title: 'About Spimr'
      stylesheet: 'about'
      info: req.flash 'info'
      error: req.flash 'error'

  app.get '/contact', (req, res) ->
    res.render "#{__dirname}/views/contact",
      title: 'Contact Us'
      stylesheet: 'about'
      info: req.flash 'info'
      error: req.flash 'error'


module.exports = routes