
require 'assert'
require 'should'

mongoose = require 'mongoose'
mongoose.connect('mongodb://localhost/spimr_test');

require '../../models/spime.coffee'
Spime = mongoose.model('Spime')


describe "Spime", ->
  spime = null
  
  before (done) ->
    spime = new Spime
    spime.save (err, saved) ->
      done()
  
  after (done) ->
    mongoose.connection.db.dropDatabase ->
      mongoose.connection.close ->
        done()
  
  it "exists", ->
    spime.should.exist
  
  it "sets uuid", ->
    spime.uuid.should.exist

