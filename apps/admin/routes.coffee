Spime = require '../../models/spime'

routes = (app) ->
  
  app.namespace '/admin', ->
    
    app.namespace '/spimes', ->
    
      app.get '/', (req, res) ->
        spime = new Spime
        res.render "#{__dirname}/views/spimes/mine",
          title: "View My Spimes"
          stylesheet: "admin"
          spime: spime

      app.post '/', (req, res) ->
        attributes =
          name: req.body.name
          description: req.body.description
          privacy: req.body.privacy
        spime = new Spime attributes
        spime.save (err, spime) ->
          #req.flash 'info', "Spime #{spime.name} was saved."
          res.redirect '/admin/spimes'
          
module.exports = routes