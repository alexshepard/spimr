
uuid = require('node-uuid')
mongoose = require 'mongoose'

Spime = new mongoose.Schema(
  name: { type: String, trim: true }
  description: { type: String }
  uuid: { type: String }
  privacy: { type: String }
  owner: { type: mongoose.Schema.ObjectId, ref: 'User' }
)

Spime.pre 'save', (next) ->
  if this.uuid and this.uuid.length
    next()
  else
    this.uuid = uuid.v4()
    next()

SpimeSighting = new mongoose.Schema(
  location_name: { type: String }
  checkin_person: { type: String }
  latitude: { type: Number }
  longitude: { type: Number }
  timestamp: { type: Date }
  spime: { type: mongoose.Schema.ObjectId, ref: 'Spime' }
)

SpimeSighting.pre 'save', (next) ->
  if this.timestamp
    next()
  else
    this.timestamp = new Date()
    next()


mongoose.model "Spime", Spime
mongoose.model "SpimeSighting", SpimeSighting

