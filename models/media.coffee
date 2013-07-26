mongoose = require 'mongoose'

MediaItem = new mongoose.Schema(
  name: { type: String, trim: true, validate: [(val) ->
      return true if val and val.length
      return false
    , 'Invalid Name']
  }
  description: { type: String }
  uploader: { type: mongoose.Schema.ObjectId, ref: 'User' }
  
  cloudinary_public_id: { type: String }
  cloudinary_format: { type: String }
  cloudinary_resource_type: { type: String }
)

mongoose.model "MediaItem", MediaItem
