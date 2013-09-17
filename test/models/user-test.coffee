require 'assert'
should = require 'should'

mongoose = require 'mongoose'

require '../../models/user.coffee'
require '../../models/spime.coffee'
User = mongoose.model('User')
Spime = mongoose.model('Spime')

mongo = null

before (done) ->
  mongo = mongoose.createConnection('mongodb://localhost/spimr_test')
  done()

after (done) ->
  mongo.db.dropDatabase()
  mongo.close()
  done()

describe "User", ->
  user = null
      
  it "exists", (done) ->
    user = new User
    user.should.exist
    done()

  it "fails without email", (done) ->
    user = new User
    user.password = "asdf"
    user.save (err) ->
      should.exist(err)
      err.message.should.equal("Validation failed")
      done()
  
  it "fails without password", (done) ->
    user = new User
    user.email = "asdf@example.com"
    user.save (err) ->
      should.exist(err)
      err.message.should.equal("Invalid password")
      done()
  
  it "saves with email and password", (done) ->
    user = new User
    user.email = "asdf@example.com"
    user.password = "asdf"
    user.save (err) ->
      should.not.exist(err)
      done()

  it "will not save with invalid(1) email", (done) ->
    user = new User
    user.email = 'alkjsdf'
    user.password = "asdf"
    user.save (err) ->
      should.exist(err)
      done()

  it "will not save with invalid(2) email", (done) ->
    user = new User
    user.email = 'alkjsdf.com'
    user.password = "asdf"
    user.save (err) ->
      should.exist(err)
      done()
  
  it "saves with valid(1) email", (done) ->
    user = new User
    user.email = 'lasdjfl@slkdjf.com'
    user.password = "asdf"
    user.save (err) ->
      should.not.exist(err)
      done()
      
  it "saves with valid(2) email", (done) ->
    user = new User
    user.email = 'la+sdj.fl@slkdjf.com'
    user.password = "asdf"
    user.save (err) ->
      should.not.exist(err)
      done()
      
  it "saves with valid(3) email", (done) ->
    user = new User
    user.email = 'lasdj.fl@slk.djf.com'
    user.password = "asdf"
    user.save (err) ->
      should.not.exist(err)
      done()

  it "deletes its spimes", (done) ->
    user = new User
    user.email = "delete-spimes-test@domain"
    user.password = "asdf"
    user.save (err) ->
      should.not.exist(err)
      spime = new Spime
      spime.owner = user
      spime.name = "user-deletes-spimes-test"
      spime.save (err) ->
        should.not.exist(err)
        user.remove (err) ->
          should.not.exist(err)
          Spime
            .findOne( { _id: spime._id } )
            .exec (err, spime) ->
              should.not.exist(err)
              should.not.exist(spime)
              done()

  it "shouldn't be admin", (done) ->
    user = new User
    user.email = "admin-test@domain"
    user.password = "asdf"
    user.save (err) ->
      should.not.exist(err)
      user.should.have.property(
        "is_admin", false
      )
      done()
