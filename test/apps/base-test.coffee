
assert = require 'assert'
request = require 'supertest'
app = require '../../app'

describe "GET /", ->
  it "responds with 200", (done) ->
    console.log "env is " + app.get('env')
    request(app)
      .get('/')
      .expect(200, done)