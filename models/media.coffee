mongoose = require 'mongoose'
cloudinary = require 'cloudinary'

MediaItem = new mongoose.Schema(
  name:
    type: String
  
  description:
    type: String
  
  uploader:
    type: mongoose.Schema.ObjectId
    ref: 'User'

  cloudinary_public_id:
    type: String
    validate: (val) -> 
      return true if val and val.length
      return false
  
  cloudinary_format:
    type: String
    validate: (val) -> 
      return true if val and val.length
      return false

  cloudinary_resource_type:
    type: String
    validate: (val) -> 
      return true if val and val.length
      return false
  
  thumbUrl:
    type: String
    default: ""
    
  compUrl:
    type: String
    default: ""
  
  largeUrl:
    type: String
    default: ""
)

MediaItem.pre 'save', (next) ->
  console.log "in mediaitem.pre save"
  # rebuild all thumbnail urls
  this.thumbUrl = cloudinary.url(this.cloudinary_public_id + '.' + this.cloudinary_format,
    {
      width: 75
      height: 75
      crop: "fill"
      radius: 10
    }
  )
  
  this.compUrl = cloudinary.url(this.cloudinary_public_id + '.' + this.cloudinary_format,
    {
      width: 150
      height: 150
      crop: "fill"
      radius: 10
    }
  )

  this.largeUrl = cloudinary.url(this.cloudinary_public_id + '.' + this.cloudinary_format,
    {
      width: 400
      height: 400
      crop: "fill"
      radius: 10
    }
  )
  next()

mongoose.model "MediaItem", MediaItem
