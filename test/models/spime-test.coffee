
require 'assert'
require 'should'

mongoose = require 'mongoose'
app = require '../../app'

require '../../models/spime.coffee'
Spime = mongoose.model('Spime')

describe "Spime", ->
  spime = null
  
  before (done) ->
    spime = new Spime
    spime.save (err, saved) ->
      done()
    
  it "exists", ->
    spime.should.exist
  
  it "sets uuid", ->
    spime.uuid.should.exist

