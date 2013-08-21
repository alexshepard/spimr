
require 'assert'
should = require 'should'

mongoose = require 'mongoose'

require '../../models/spime.coffee'
Spime = mongoose.model('Spime')

describe "Spime", ->
  spime = null
  mongo = null
  
  before (done) ->
    mongo = mongoose.createConnection('mongodb://localhost/spimr_test');
    done()
  
  after (done) ->
    mongo.db.dropDatabase()
    mongo.close()
    done()
    
  it "exists", ->
    spime = new Spime
    spime.should.exist
  
  it "requires name", (done) ->
    spime = new Spime
    spime.save (err) ->
      should.exist(err)
      done()
  
  it "saves with name", (done) ->
    spime = new Spime
    spime.name = "name-test"
    spime.save (err) ->
      should.not.exist(err)
      done()
    
  it "sets uuid", (done) ->
    spime = new Spime
    spime.name = 'uuid-test'
    spime.save (err) ->
      spime.should.have.property('uuid')
      done()

  it "deletes its media", (done) ->
    done()
    
  it "deletes its sightings", (done) ->
    done()
