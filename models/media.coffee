mongoose = require 'mongoose'
cloudinary = require 'cloudinary'
util = require 'util'
fs = require 'fs'
path = require 'path'

schemaOptions = {
  toObject:
    virtuals: true
}

MediaItem = new mongoose.Schema(
  name:
    type: String
  
  description:
    type: String
  
  data_source_name:
    type: String
    required: true
  
  uploader:
    type: mongoose.Schema.ObjectId
    ref: 'User'

  media_item_id:
    type: String
  
  media_format:
    type: String
      
, schemaOptions)


MediaItem.virtual('data_source').get ->
  new named_classes[this.data_source_name]

MediaItem.virtual('thumb_url').get ->
  if this.media_item_id
    ds = new named_classes[this.data_source_name]
    ds.thumb_url(this.media_item_id, this.media_format)

MediaItem.virtual('comp_url').get ->
  if this.media_item_id
    ds = new named_classes[this.data_source_name]
    ds.comp_url(this.media_item_id, this.media_format)

MediaItem.virtual('large_url').get ->
  if this.media_item_id?
    ds = new named_classes[this.data_source_name]
    ds.large_url(this.media_item_id, this.media_format)
    

MediaItem.method 'save_media', (media_item_tmp, callback) ->
  this.data_source.save(media_item_tmp, callback)

MediaItem.method 'delete_media', (callback) ->
  if this.media_item_id  
    this.data_source.delete(this.media_item_id, callback)

MediaItem.pre 'remove', (next) ->
  this.delete_media (result) ->
    
  next()

mongoose.model "MediaItem", MediaItem

class CloudinaryMediaDataSource
  
  save: (media_item_temp, callback) ->
    stream = cloudinary.uploader.upload_stream((result) ->
      callback(result)
    ,
    { width: 1000, height: 1000, crop: "limit" }
    )
    fs
      .createReadStream(media_item_temp.path,encoding: "binary")
      .on("data", stream.write)
      .on "end", stream.end

  
  delete: (media_item_id, callback) ->
    cloudinary.api.delete_resources(media_item_id, (result) ->
      callback(result)
    )
  
  thumb_url: (media_item_id, media_item_format) ->
    cloudinary.url(media_item_id + '.' + media_item_format,
      {
        width: 75
        height: 75
        crop: "fill"
        radius: 10
      }
    )
  
  comp_url: (media_item_id, media_item_format) ->
    cloudinary.url(media_item_id + '.' + media_item_format,
      {
        width: 150
        height: 150
        crop: "fill"
        radius: 10
      }
    )
  
  large_url: (media_item_id, media_item_format) ->
    cloudinary.url(media_item_id + '.' + media_item_format,
      {
        width: 400
        height: 400
        crop: "fill"
        radius: 10
      }
    )


class LocalMediaDataSource
  
  constructor: ->
    @path = "/tmp/spimr_media"
    fs.mkdirSync @path unless fs.existsSync @path
  
  save: (media_item_tmp, callback) ->
    # collision is likely here
    # should I generate unique name to this file?
    # ie basename = fs.uniqueName()
    # or use node-temp npm module 
         
    # this seems to be a unique name
    basename = path.basename(media_item_tmp.path)
    # path.extname returns .JPG, we want JPG
    ext = path
          .extname(media_item_tmp.name)
          .substring(1)
    save_path = path.join(@path, basename + '.' + ext)
    
    # blindly assume this all works
    fs
      .createReadStream(media_item_tmp.path)
      .pipe(fs.createWriteStream(save_path))
  
    # callback must return public_id and format
    callback
      public_id: basename
      format: ext

  delete: (media_item_id, callback) ->
    delete_path = path.join(@path, media_item_id)
    fs.unlinkSync(delete_path)
    callback()
      
  
  thumb_url: (media_item_id, media_item_format) ->
    return @path + '/' + media_item_id + '.' + media_item_format
  
  comp_url: (media_item_id, media_item_format) ->
    return @path + '/' + media_item_id + '.' + media_item_format

  large_url: (media_item_id, media_item_format) ->
    return @path + '/' + media_item_id + '.' + media_item_format

# construct the correct data source based on the stashed one
named_classes =
  CloudinaryMediaDataSource: CloudinaryMediaDataSource
  LocalMediaDataSource: LocalMediaDataSource
