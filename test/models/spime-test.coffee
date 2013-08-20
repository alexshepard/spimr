
require 'assert'
require 'should'

mongoose = require 'mongoose'

require '../../models/spime.coffee'
Spime = mongoose.model('Spime')

describe "Spime", ->
  spime = null
  
  before (done) ->
    mongoose.createConnection('mongodb://localhost/spimr_test');
    spime = new Spime
    spime.save (err, saved) ->
      done()
  
  after (done) ->
    mongoose.connection.close()
    done()
    
  it "exists", ->
    spime.should.exist
  
  it "sets uuid", ->
    spime.uuid.should.exist

