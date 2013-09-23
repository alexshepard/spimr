
assert = require 'assert'
request = require 'supertest'
should = require 'should'

app = require '../../app'

describe "Bad login", ->
  it "fails", (done) ->
    request(app)
      .post('/sessions')
      .send({ email: "bad-login@example", password: 'password' })
      .expect(500, done)

describe "Create account", ->
  it "succeeds", (done) ->
    request(app)
      .post('/people/new')
      .send
        "email": "create-account@example.com"
        "password": "asdf"
      .end (err, res) ->
        res.statusCode.should.equal(302)
        res.header['location'].should.include('/')
        done()
        
describe "Good login", ->
  it "succeeds", (done) ->
    request(app)
      .post('/sessions')
      .send({ email: "create-account@example.com", password: 'asdf' })
      .end (err, res) ->
        res.statusCode.should.equal(302)
        res.header['location'].should.include('/')
        done()