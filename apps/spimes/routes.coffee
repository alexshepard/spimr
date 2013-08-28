mongoose = require 'mongoose'

Spime = require '../../models/spime'
User = require '../../models/user'
MediaItem = require '../../models/media.coffee'

routes = (app) ->
  
  app.namespace '/spimes', ->
  
    app.get '/mine', (req, res, next) ->
      app.locals.requiresLogin(req, res)
      Spime = mongoose.model('Spime')
      Spime.find({ owner: req.session.user_id}).populate('owner').populate('photo').populate('last_sighting').exec (err, spimes) ->
        return next(err) if err?
        if spimes?
          res.render "#{__dirname}/views/mine",
            title: "My Spimes"
            stylesheet: "admin"
            spimes: spimes
            info: req.flash 'info'
            error: req.flash 'error'

    app.get '/new', (req, res, next) ->
      app.locals.requiresLogin(req, res)
      Spime = mongoose.model('Spime')
      spime = new Spime()
      res.render "#{__dirname}/views/new",
        title: "New Spime"
        stylesheet: "admin"
        spime: spime
        info: req.flash 'info'
        error: req.flash 'error'

    app.get '/:id', (req, res, next) ->
      Spime = mongoose.model('Spime')
      SpimeSighting = mongoose.model('SpimeSighting')
      Spime.findOne({ _id: req.params.id }).populate('owner').populate('photo').populate('last_sighting').exec (err, spime) ->
        return next(err) if err?
        if spime?
          if spime.privacy == 'public' || spime.owner.id == req.session.user_id
            spime.checkin_url = app.locals.checkinUrlForUuid(req, spime.uuid)
            SpimeSighting.find({ spime: req.params.id }).exec (err, sightings) ->
              return next(err) if err?
              res.render "#{__dirname}/views/spime",
                title: spime.name
                stylesheet: "spime"
                spime: spime
                sightings: sightings
                info: req.flash 'info'
                error: req.flash 'error'
              return
          else
            req.flash 'error', 'Permission denied.'
            res.redirect '/'
            return
        else
          res.send(404)
    
    app.get '/', (req, res, next) ->
      Spime = mongoose.model('Spime')
      Spime.find({ privacy: 'public'}).populate('owner').populate('photo').populate('last_sighting').exec (err, spimes) ->
        return next(err) if err?
        if spimes?
          res.render "#{__dirname}/views/public",
            title: 'Public Spimes'
            stylesheet: "spimr"
            spimes: spimes
            info: req.flash 'info'
            error: req.flash 'error'
          return
        res.send(404)
    
    app.get '/edit/:id', (req, res, next) ->
      app.locals.requiresLogin(req, res)
      Spime = mongoose.model('Spime')
      Spime.findOne({ _id: req.params.id }).populate('owner').populate('photo').exec (err, spime) ->
        return next(err) if err?
        if spime?
          if String(req.session.user_id) != String(spime.owner._id)
            req.flash 'error', 'Permission denied.'
            res.redirect '/'
            return
          res.render "#{__dirname}/views/edit",
            title: "Edit #{spime.name}"
            stylesheet: "admin"
            spime: spime
            info: req.flash 'info'
            error: req.flash 'error'
          return
        res.send(404)
  
    app.post '/', (req, res, next) ->
      app.locals.requiresLogin(req, res)
      User = mongoose.model('User')
      User.findById req.session.user_id, (err, user) ->
        return next(err) if err?
        if user?
          Spime = mongoose.model('Spime')
          attributes = req.body
          spime = new Spime(attributes)
          spime.owner = user._id
          spime.save (err, saved) ->
            if err?
              req.flash 'error', 'Error creating spime: ' + err.errors.name.type
              res.redirect "/spimes/mine"
              return
            else
              if spime.privacy == 'public'
                twitString = "#{spime.name} was just created on Spimr: #{app.locals.baseUrl(req)}/spimes/#{spime._id}"
                app.twit
                  .updateStatus twitString, (data) ->
                    console.log data

              req.flash 'info', 'Spime created.'
              res.redirect "/spimes/edit/#{saved._id}"
              return
  
    app.post '/image', (req, res, next) ->
      app.locals.requiresLogin(req, res)
      User = mongoose.model('User')
      User.findById req.session.user_id, (err, user) ->
        return next(err) if err?
        (res.send(404, { error: 'No Such User' }); return;) if !user?
        Spime = mongoose.model('Spime')
        Spime.findOne({ _id: req.body._spime }).populate('photo').exec (err, spime) ->
          return next(err) if err?
          (res.send(404, { error: 'No Such Spime' }); return;) if !spime?
          if spime.owner is not user._id
            req.flash 'error', 'Permission denied.'
            res.redirect '/spimes/mine'
            return
          MediaItem = mongoose.model('MediaItem')
          photo = new MediaItem
          photo.data_source_name = 'CloudinaryMediaDataSource'
          photo.save_media(req.files.photo, (result) ->
            photo.media_item_id = result.public_id
            photo.media_format = result.format
            photo.uploader = user
            photo.save (err, save) ->
              return next(err) if err?
              if save?
                spime.photo = photo
                spime.save (err, save) ->
                  return next(err) if err?
                  req.flash 'info', 'Spime saved.'
                  res.redirect "/spimes/#{spime._id}"
                  return
          )
      

    app.put '/:id', (req, res, next) ->
      app.locals.requiresLogin(req, res)
      Spime = mongoose.model('Spime')
      Spime.findOne({ _id: req.params.id }).populate('owner').exec (err, spime) ->
        return next(err) if err?
        if spime?
          if String(req.session.user_id) != String(spime.owner._id)
            req.flash 'error', 'Permission denied.'
            res.redirect '/'
            return
          for attr,value of req.body
            spime.set(attr, value)
          spime.save (err, save) ->
            return next(err) if err?
            if save?
              req.flash 'info', 'Spime edited.'
              res.redirect "/spimes/#{req.params.id}"
              return
            else
              res.send(404)
        else
          res.send(404)
  
    app.delete '/image/:id', (req, res, next) ->
      app.locals.requiresLogin(req, res)
      MediaItem = mongoose.model('MediaItem')
      MediaItem.findOne({ _id: req.params.id }).populate('uploader').exec (err, image) ->
        return next(err) if err?
        if image?
          if req.session.user_id != String(image.uploader._id)
            req.flash 'error', 'Permission denied.'
            res.redirect '/'
            return
          # delete all references to this photo among spimes
          Spime = mongoose.model('Spime')
          Spime.find ({ photo: image._id }), (err, spimes) ->
            return next(err) if err?
            if spimes?
              for spime in spimes
                spime.photo = null
                spime.save (err, saved) ->
                  return next(err) if err?
                  req.flash 'info', 'Photo deleted.'
                  res.redirect '/spimes/mine'
                  return
      
    app.delete '/:id', (req, res, next) ->
      app.locals.requiresLogin(req, res)
      Spime = mongoose.model('Spime')
      Spime.findById req.params.id, (err, spime) ->
        return next(err) if err?
        if spime?
          if req.session.user_id != String(spime.owner)
            req.flash 'error', 'Permission denied.'
            res.redirect '/'
            return
          spime.remove (err, spime) ->
            return next(err) if err?
            req.flash 'info', 'Spime deleted.'
            res.redirect '/spimes/mine'

    
module.exports = routes