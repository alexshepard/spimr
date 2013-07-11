

helpers = (app) ->
  
  # todo - rewrite this to not be spime-specific
  app.locals
    urlFor: (obj) ->
      # all objects will have some privacy setting or another
      if obj.privacy
        "/admin/spimes/#{obj.id}"
      else
        "/admin/spimes"


module.exports = helpers