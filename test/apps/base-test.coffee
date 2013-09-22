
assert = require 'assert'
request = require 'supertest'
app = require '../../app'

describe "GET /", ->
  it "responds with 200", (done) ->
    request(app)
      .get('/')
      .expect(200, done)

describe "GET /about", ->
  it "responds with 200", (done) ->
    request(app)
      .get('/about')
      .expect(200, done)
