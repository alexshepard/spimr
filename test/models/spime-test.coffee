
require 'assert'
should = require 'should'

mongoose = require 'mongoose'

require '../../models/spime.coffee'
Spime = mongoose.model('Spime')
SpimeSighting = mongoose.model('SpimeSighting')

mongo = null

before (done) ->
  mongo = mongoose.createConnection('mongodb://localhost/spimr_test');
  done()

after (done) ->
  mongo.db.dropDatabase()
  mongo.close()
  done()

describe "Spime", ->
  spime = null
      
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
      should.not.exist(err)
      spime.should.have.property('uuid')
      done()

  it "deletes its media", (done) ->
    done()
    
  it "deletes its sightings", (done) ->
    spime = new Spime
    spime.name = "deletes sighting-test"
    spime.save (err) ->
      should.not.exist(err)
      sighting = new SpimeSighting
      sighting.spime = spime
      sighting.save (err) ->
        should.not.exist(err)
        spime.remove (err) ->
          should.not.exist(err)
          SpimeSighting
            .findOne( { _id: sighting._id } )
            .exec (err, sighting) ->
              should.not.exist(err)
              should.not.exist(sighting)
              done() 

describe "SpimeSighting", ->
  sighting = null
  
  it "exists", ->
    sighting = new SpimeSighting
    sighting.should.exist
  
  it "requires a spime", (done) ->
    sighting = new SpimeSighting
    sighting.save (err) ->
      should.exist(err)
      done()
  
  it "saves with a spime", (done) ->
    sighting = new SpimeSighting
    spime = new Spime
    sighting.spime = spime
    sighting.save (err) ->
      should.not.exist(err)
      done()
  
  it "sets timestamp", (done) ->
    sighting = new SpimeSighting
    spime = new Spime
    sighting.spime = spime
    sighting.save (err) ->
      should.not.exist(err)
      sighting.should.have.property('timestamp')
      done()
    