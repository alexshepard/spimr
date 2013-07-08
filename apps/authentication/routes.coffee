
routes = (app) ->

  app.get '/login', (req, res) ->
    res.render "#{__dirname}/views/login",
      title: 'Login'
      stylesheet: 'login'
      info: req.flash 'info'
      error: req.flash 'error'
    
  app.post '/sessions', (req, res) ->
    # TODO - handle real authentication
    if ('wrangler' is req.body.user) and ('54321abcde' is req.body.password)
      req.session.currentUser = req.body.user
      req.flash 'info', "You are logged in as #{req.session.currentUser}."
      res.redirect '/login'
      return
    req.flash 'error', 'Those credentials were incorrect. Try again.'
    res.redirect '/login'
  
  app.del '/sessions',  (req, res) ->
    req.sessions.regenerate (err) ->
      req.flash 'info', 'You have been logged out.'
      res.redirect '/login'

module.exports = routes