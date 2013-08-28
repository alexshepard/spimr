require 'assert'
should = require 'should'

mongoose = require 'mongoose'

require '../../models/spime.coffee'
MediaItem = mongoose.model('MediaItem')

# mediaitem unit tests use the local media source
# not s3 or cloudinary
# s3 and/or cloudinary support will have to be tested elsewhere

describe "MediaItem", ->
  media_item = null
  mongo = null
  
  it "exists", ->
    media_item = new MediaItem
    media_item.should.exist
  
  it "requires media source", (done) ->
    media_item = new MediaItem
    media_item.save (err) ->
      should.exist(err)
      err.message.should.equal("Validation failed")
      done()
  
  it "saves with media source name", (done) ->
    media_item = new MediaItem
    media_item.data_source_name = "LocalMediaDataSource"
    media_item.save (err) ->
      should.not.exist(err)
      done()
  
