mongoose = require 'mongoose'
Spime = require '../../models/spime'

routes = (app) ->

  app.get '/', (req, res) ->
    Spime = mongoose.model('Spime')
    Spime = mongoose.model('Spime')
    Spime.find({ privacy: 'public'}).populate('owner').exec (err, spimes) ->
      res.send(500, { error: err}) if err?
      if spimes?
        res.render "#{__dirname}/views/base",
          title: 'Public Spimes'
          stylesheet: "spimr"
          spimes: spimes
          info: req.flash 'info'
          error: req.flash 'error'
        return
      res.send(404)

  app.get '/about', (req, res) ->
    res.render "#{__dirname}/views/about",
      title: 'About Spimr'
      stylesheet: 'about'
      info: req.flash 'info'
      error: req.flash 'error'


module.exports = routes