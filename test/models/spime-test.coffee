
assert = require 'assert'
Spime = require '../../models/spime.coffee'

describe "Spime", ->
  describe 'create', ->
    spime = null
    before ->
      spime = new Spime
  
    it "sets uuid", ->
      assert(spime.hasOwnProperty("uuid"))