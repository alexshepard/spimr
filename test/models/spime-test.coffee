
require 'assert'
should = require 'should'

mongoose = require 'mongoose'

require '../../models/spime.coffee'
Spime = mongoose.model('Spime')
SpimeSighting = mongoose.model('SpimeSighting')
MediaItem = mongoose.model('MediaItem')

mongo = null

before (done) ->
  mongo = mongoose.createConnection('mongodb://localhost/spimr_test')
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

  it "edits fields", (done) ->
    spime = new Spime
    spime.name = "edit-fields-test"
    spime.description = "A description"
    spime.safety = "A safety"
    spime.save (err) ->
      should.not.exist(err)
      Spime
        .findOne({ _id: spime._id })
        .exec (err, foundSpime) ->
          should.not.exist(err)
          should.exist(foundSpime)
          foundSpime.description = "Another description"
          foundSpime.safety = "Another safety"
          foundSpime.save (err) ->
            should.not.exist(err)
            Spime
              .findOne({ _id: foundSpime._id })
              .exec (err, editedSpime) ->
                should.not.exist(err)
                should.exist(editedSpime)
                editedSpime.should.have.property(
                  "description", "Another description"
                )
                editedSpime.should.have.property(
                  "safety", "Another safety"
                )
                done()
  
  it "deletes its media", (done) ->
    spime = new Spime
    spime.name = "deletes media-test"
    mediaItem = new MediaItem
    mediaItem.data_source_name = 'LocalMediaDataSource'
    spime.photo = mediaItem
    spime.save (err) ->
      should.not.exist(err)
      mediaItem.save (err) ->
        should.not.exist(err)
        spime.remove (err) ->
          should.not.exist(err)
          MediaItem
            .findOne({ _id: mediaItem._id })
            .exec (err, mediaItem) ->
              should.not.exist(err)
              should.not.exist(mediaItem)
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
    