

helpers = (app) ->
  
  # todo - rewrite this to not be spime-specific
  app.locals
    urlFor: (obj) ->
      if obj
        "/admin/spimes/#{obj.id}"
      else
        "/admin/spimes"
#      if obj.id
#        "/admin/spimes/#{obj.id}"
#      else
#        "/admin/spimes"


module.exports = helpers