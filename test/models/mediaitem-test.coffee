require 'assert'
should = require 'should'

mongoose = require 'mongoose'

require '../../models/spime.coffee'
MediaItem = mongoose.model('MediaItem')

describe "MediaItem", ->
  media_item = null
  mongo = null