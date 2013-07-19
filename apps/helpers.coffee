

helpers = (app) ->
  
  # todo - rewrite this to not be spime-specific
  app.locals
    urlFor: (obj) ->
      # all objects will have some privacy setting or another
      if obj.privacy
        "/admin/spimes/#{obj.id}"
      else
        "/admin/spimes"
    checkinUrlForUuid: (req, uuid) ->
      # construct checkin url
      port = app.settings.port;
      port_section = ''
      if ('development' == app.get('env') and (port != 80 and port != 443))
        port_section = ":#{port}"        
      return "#{req.protocol}://#{req.host}#{port_section}/checkin/#{uuid}"


module.exports = helpers