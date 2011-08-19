connect    = require('connect')
browserify = require('browserify')
fileify    = require('fileify')

server = connect.createServer()

server.use connect.logger()

server.use (req, res, next) ->
  n = Number(req.url[1..-1])
  req.url = "/index.html" if n >= 0
  next()

server.use connect.static(__dirname + '/public')

bundle = browserify(entry: __dirname + '/browser.coffee', watch: true)
bundle.use(fileify('levels', __dirname + '/levels', extension: '.txt', watch: true))
server.use(bundle)

port = process.env.PORT || 3000
server.listen(port)
console.log "Listening on port #{port}"

