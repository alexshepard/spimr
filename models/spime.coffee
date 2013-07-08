
uuid = require('node-uuid')
mongoose = require 'mongoose'

Spime = new mongoose.Schema(
  name: { type: String, trim: true }
  description: { type: String }
  uuid: { type: String }
  privacy: { type: String }
)

mongoose.model "Spime", Spime