mongoose = require 'mongoose'
cloudinary = require 'cloudinary'
fs = require 'fs'

Spime = require '../../models/spime'
User = require '../../models/user'
MediaItem = require '../../models/media.coffee'

routes = (app) ->
  
  app.namespace '/spimes', ->
  
    app.get '/mine', (req, res) ->
      app.locals.requiresLogin(req, res)
      Spime = mongoose.model('Spime')
      Spime.find({ owner: req.session.user_id}).populate('owner').populate('photo').exec (err, spimes) ->
        if spimes?
          for spime in spimes
            if spime.photo? and spime.photo.cloudinary_public_id?
              spime.thumbUrl = cloudinary.url(spime.photo.cloudinary_public_id + '.' + spime.photo.cloudinary_format,
                { width: 45, height: 45, crop: "fill", radius: 10 })
          res.render "#{__dirname}/views/mine",
            title: "My Spimes"
            stylesheet: "admin"
            spimes: spimes
            info: req.flash 'info'
            error: req.flash 'error'

    app.get '/new', (req, res) ->
      app.locals.requiresLogin(req, res)
      Spime = mongoose.model('Spime')
      spime = new Spime()
      res.render "#{__dirname}/views/new",
        title: res.name
        stylesheet: "admin"
        spime: spime
        info: req.flash 'info'
        error: req.flash 'error'

    app.get '/:id', (req, res) ->
      Spime = mongoose.model('Spime')
      Spime.findOne({ _id: req.params.id }).populate('owner').populate('photo').exec (err, spime) ->
        res.send(500, { error: err }) if err?
        if spime?
          if spime.photo? and spime.photo.cloudinary_public_id?
            spime.photoUrl = cloudinary.url(spime.photo.cloudinary_public_id + '.' + spime.photo.cloudinary_format,
              { width: 400, height: 400, crop: "fill", radius: 10 })
          if spime.privacy == 'public' || spime.owner.id == req.session.user_id
            spime.checkin_url = app.locals.checkinUrlForUuid(req, spime.uuid)
            res.render "#{__dirname}/views/spime",
              title: res.name
              stylesheet: "spime"
              spime: spime
              info: req.flash 'info'
              error: req.flash 'error'
            return
          else
            req.flash 'error', 'Permission denied.'
            res.redirect '/'
            return
        res.send(404)
    
    app.get '/', (req, res) ->
      Spime = mongoose.model('Spime')
      Spime.find({ privacy: 'public'}).populate('owner').populate('photo').exec (err, spimes) ->
        res.send(500, { error: err}) if err?
        if spimes?
          for spime in spimes
            if spime.photo? and spime.photo.cloudinary_public_id?
              spime.thumbUrl = cloudinary.url(spime.photo.cloudinary_public_id + '.' + spime.photo.cloudinary_format,
                { width: 45, height: 45, crop: "fill", radius: 10 })
          res.render "#{__dirname}/views/public",
            title: 'Public Spimes'
            stylesheet: "spimr"
            spimes: spimes
            info: req.flash 'info'
            error: req.flash 'error'
          return
        res.send(404)
    
    app.get '/edit/:id', (req, res) ->
      app.locals.requiresLogin(req, res)
      Spime = mongoose.model('Spime')
      Spime.findById req.params.id, (err, spime) ->
        res.send(500, { error: err}) if err?
        if spime?
          if req.session.user_id != String(spime.owner)
            req.flash 'error', 'Permission denied.'
            res.redirect '/'
            return
          res.render "#{__dirname}/views/edit",
            title: res.name
            stylesheet: "admin"
            spime: spime
            info: req.flash 'info'
            error: req.flash 'error'
          return
        res.send(404)
  
    app.post '/', (req, res) ->
      app.locals.requiresLogin(req, res)
      User = mongoose.model('User')
      User.findById req.session.user_id, (err, user) ->
        res.send(500, { error: err }) if err?
        if user?
          Spime = mongoose.model('Spime')
          attributes = req.body
          spime = new Spime(attributes)
          spime.owner = user._id
          spime.save (err, saved) ->
            if err?
              req.flash 'error', 'Error creating spime: ' + err.errors.name.type
            else
              req.flash 'info', 'Spime created.'
            res.redirect '/spimes/mine'
            return
  
    app.post '/image', (req, res) ->
      app.locals.requiresLogin(req, res)
      User = mongoose.model('User')
      User.findById req.session.user_id, (err, user) ->
        (res.send(500, { error: err }); return;) if err?
        (res.send(404, { error: 'No Such User' }); return;) if !user?
        Spime = mongoose.model('Spime')
        Spime.findById req.body._spime, (err, spime) ->
          (res.send(500, { error: err }); return;) if err?
          (res.send(404, { error: 'No Such Spime' }); return;) if !spime?
          if spime.owner is not user._id
            req.flash 'error', 'Permission denied.'
            res.redirect '/spimes/mine'
            return
          stream = cloudinary.uploader.upload_stream((result) ->
            (res.send(404, { error: 'No Upload Possible' }); return;) if !result?
            if result?
              console.log result
              MediaItem = mongoose.model('MediaItem')
              photo = new MediaItem
              photo.cloudinary_public_id = result.public_id
              photo.cloudinary_format = result.format
              photo.cloudinary_resource_type = result.resource_type
              photo.name = req.body.imageTitle
              photo.uploader = user._id                
              photo.save (err, saved) ->
                (res.send(500, { error: err }); return;) if err?
                spime.update { $set : { photo: photo._id } }, (err, update) ->
                  (res.send(500, { error: err }); return;) if err?
                  req.flash 'info', 'Photo saved.'
                  res.redirect '/spimes/' + spime._id
                  return
          ,
            { width: 1000, height: 1000, crop: "limit" }
          )
          fs.createReadStream(req.files.image.path,
            encoding: "binary"
          ).on("data", stream.write).on "end", stream.end


    app.put '/:id', (req, res) ->
      app.locals.requiresLogin(req, res)
      Spime = mongoose.model('Spime')
      Spime.findById req.params.id, (err, spime) ->
        res.send(500,  { error: err}) if err?
        if spime?
          if req.session.user_id != String(spime.owner)
            req.flash 'error', 'Permission denied.'
            res.redirect '/'
            return
          
          attributes = req.body
          Spime.findByIdAndUpdate(req.params.id, { $set: attributes }).populate('owner').exec (updateErr, updatedSpime) ->
            res.send(500, { error: updateErr}) if updateErr?
            if updatedSpime?
              req.flash 'info', 'Spime edited.'
              res.redirect "/spimes/#{req.params.id}"
              return
            else
              res.send(404)
        else
          res.send(404)
  
    app.delete '/:id', (req, res) ->
      app.locals.requiresLogin(req, res)
      Spime = mongoose.model('Spime')
      Spime.findById req.params.id, (err, spime) ->
        res.send(500,  { error: err}) if err?
        if spime?
          if req.session.user_id != String(spime.owner)
            req.flash 'error', 'Permission denied.'
            res.redirect '/'
            return
          spime.remove (err, spime) ->
            res.send(500, { error: err }) if err?
            req.flash 'info', 'Spime deleted.'
            res.redirect '/spimes/mine'

    
module.exports = routes