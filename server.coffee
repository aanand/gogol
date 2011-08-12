connect    = require('connect')
browserify = require('browserify')

server = connect.createServer()

server.use connect.static(__dirname + '/public')
server.use browserify(
  entry: __dirname + '/browser.coffee'
)

server.listen 9797

