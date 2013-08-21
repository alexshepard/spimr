
uuid = require('node-uuid')

mongoose = require 'mongoose'
MediaItem = require './media.coffee'


Spime = new mongoose.Schema(

  # most of these properties are shamelessly stolen from @bruces's Shaping Things

  # who owns it?
  owner:
    type: mongoose.Schema.ObjectId
    ref: 'User'

  # what's its unique uuid for tracking via arphid and qrcode?
  uuid: 
    type: String
    index: { unique: true }
    
  # where was it last?
  last_sighting:
    type: mongoose.Schema.ObjectId
    ref: 'SpimeSighting'
    default: null
    

  # user editable properties
  # what's its name?
  name:
    type: String
    trim: true
    required: true
    validate: [(val) ->
      return true if val and val.length
      return false
    , 'Invalid Name']

  # what's its story?  
  description:
    type: String

  # who can learn about it?
  privacy:
    type: String
  
  # when was it made?
  manufacturing_date:
    type: Date
    default: null
    
  # how does it perform in real life?
  functional_principles:
    type: String
    default: ""
  
  # how does it fit in? how does it say it fits in?
  regulations_and_standards:
    type: String
    default: ""
    
  # what does it cost to make it work? energy, resources, etc?
  running_cost:
    type: String
    default: ""
  
  # is it safe? according to who? references to gov'ts, ngos, etc
  safety:
    type: String
    default: ""
  
  # how much can it do?
  capacity:
    type: String
    default: ""
  
  # what are the byproducts? health side effects?
  hygiene:
    type: String
    default: ""
  
  # how to maintain and service it?
  service:
    type: String
    default: ""
  
  # how long will it last? how will it decay? how to recycle it?
  decay_and_recycling:
    type: String
    default: ""
  
  # how is it used? what are its limitations?
  uses_and_limitations:
    type: String
    default: ""
  
  # how is it legally controlled?
  patents_rights:
    type: String
    default: ""
  
  # what's it made from?
  materials:
    type: String
    default: ""
  
  # how was it made?
  construction_method:
    type: String
    default: ""
  
  # how is/was it packaged?
  packaging:
    type: String
    default: ""
  
  # how is it stored?
  storage:
    type: String
    default: ""
  
  # how was it distributed?
  distribution:
    type: String
    default: ""
  
  # what did it cost?
  price:
    type: String
    default: ""
  
  # what does it feel like?  
  haptics:
    type: String
    default: ""
  
  # what does it look like?
  photo:
    type: mongoose.Schema.ObjectId
    ref: 'MediaItem'
    default: null

)

Spime.pre 'save', (next) ->
  if this.uuid and this.uuid.length
    next()
  else
    this.uuid = uuid.v4()
    next()

Spime.pre 'remove', (next) ->
  # delete sightings
  SpimeSighting = mongoose.model('SpimeSighting')
  SpimeSighting.find({ spime: this._id}).exec (err, sightings) ->
    if err?
      next(new Error('Error getting spimes'))
    else
      sightings.map (sighting) ->
        sighting.remove (err, status) ->
          if err?
            next(new Error('Error deleting sighting'))
            console.log "unable to remove sighting while deleting spime: "
            console.log err
    
  # delete media
  MediaItem = mongoose.model('MediaItem')
  MediaItem.findOne({ _id: this.photo }).exec (err, photo) ->
    if err?
      next(new Error('Error getting media'))
    else
      if photo?
        photo.remove (err, response) ->
          if err?
            next(new Error('Error deleting photo'))
            console.log "unable to remove image while deleting spime: "
            console.log err
  next()



SpimeSighting = new mongoose.Schema(
  location_name: { type: String }
  checkin_person: { type: String }
  latitude: { type: Number }
  longitude: { type: Number }
  timestamp: { type: Date }
  spime: { type: mongoose.Schema.ObjectId, required: true, ref: 'Spime' }
)

SpimeSighting.pre 'save', (next) ->
  if this.timestamp
    next()
  else
    this.timestamp = new Date()
    next()



mongoose.model "Spime", Spime
mongoose.model "SpimeSighting", SpimeSighting

