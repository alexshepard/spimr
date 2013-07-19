

helpers = (app) ->
  
  # todo - rewrite this to not be spime-specific
  app.locals
    urlFor: (obj) ->
      # all objects will have some privacy setting or another
      if obj.privacy
        "/spimes/#{obj.id}"
      else
        "/spimes"
    checkinUrlForUuid: (req, uuid) ->
      # construct checkin url
      port = app.settings.port;
      port_section = ''
      if ('development' == app.get('env') and (port != 80 and port != 443))
        port_section = ":#{port}"        
      return "#{req.protocol}://#{req.host}#{port_section}/checkin/#{uuid}"
    
    requiresLogin: (req, res) ->
      # TODO: could probably do a better job here
      if not (req.session.user_id)
        req.flash 'error', 'Please login.'
        res.redirect '/'
        return


module.exports = helpers