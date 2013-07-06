
uuid = require('node-uuid')

# TODO - should use mongo for this?
redis = require('redis').createClient()

class Spime
  @key: ->
    "Spime:#{process.env.NODE_ENV}"
  
  constructor: (attributes) ->
    @[key] = value for key, value of attributes
    @setDefaults()
    @
  
  setDefaults: ->
    @generateUUID()
  
  generateUUID: ->
    unless @uuid
      @uuid = uuid.v4()
  
  save: (callback) ->
    @generateUUID()
    redis.hset Spime.key(), @uuid, JSON.stringify(@), (err, code) =>
      callback null, @


module.exports = Spime