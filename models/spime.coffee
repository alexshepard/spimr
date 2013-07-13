
uuid = require('node-uuid')
mongoose = require 'mongoose'

Spime = new mongoose.Schema(
  name: { type: String, trim: true }
  description: { type: String }
  uuid: { type: String }
  privacy: { type: String }
)

Spime.pre 'save', (next) ->
  if this.uuid and this.uuid.length
    next()
  else
    this.uuid = uuid.v4()
    next()

mongoose.model "Spime", Spime
