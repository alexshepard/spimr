
uuid = require('node-uuid')

class Spime
  
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

module.exports = Spime