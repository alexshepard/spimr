mongoose = require 'mongoose'
cloudinary = require 'cloudinary'

schemaOptions = {
  toObject:
    virtuals: true
}

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
    
, schemaOptions)

MediaItem.virtual('thumbUrl').get ->
  cloudinary.url(this.cloudinary_public_id + '.' + this.cloudinary_format,
      {
        width: 75
        height: 75
        crop: "fill"
        radius: 10
      }
    )

MediaItem.virtual('compUrl').get ->
  cloudinary.url(this.cloudinary_public_id + '.' + this.cloudinary_format,
      {
        width: 150
        height: 150
        crop: "fill"
        radius: 10
      }
    )

MediaItem.virtual('largeUrl').get ->
  cloudinary.url(this.cloudinary_public_id + '.' + this.cloudinary_format,
      {
        width: 400
        height: 400
        crop: "fill"
        radius: 10
      }
    )

MediaItem.pre 'remove', (next) ->
  cloudinary.api.delete_resources(this.cloudinary_public_id, (result) ->
  )
  next()


mongoose.model "MediaItem", MediaItem
