
uuid = require('node-uuid')
mongoose = require 'mongoose'  
crypto = require 'crypto'

User = new mongoose.Schema(
  email: { type: String, index: { unique: true}, validate: (val) -> 
    return true if val and val.length
    return false
  }
  hashed_password: { type: String }
  salt: { type: String }
)

User.virtual('id').get ->
  return this._id.toHexString();

User.virtual('password').get ->
  return this._password;

User.virtual('password').set (password) ->
  this._password = password;
  this.salt = this.makeSalt()
  this.hashed_password = this.encryptPassword(password)

User.method 'authenticate', (plainText) ->
  # TODO: should this be triple =? why?
  return this.encryptPassword(plainText) == this.hashed_password

User.method 'makeSalt', ->
  date = new Date
  return date.valueOf() + Math.random() + ''

User.method 'encryptPassword', (password) ->
  return crypto.createHmac('sha1', this.salt).update(password).digest('hex')

User.pre 'save', (next) ->
  # TODO: what is next() in this context?
  if this.password and this.password.length
    next()
  else
    next(new Error('Invalid password'))

mongoose.model "User", User