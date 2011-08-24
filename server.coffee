express    = require('express')
browserify = require('browserify')
fileify    = require('fileify')
fs         = require('fs')

server = express.createServer()

server.use express.logger()
server.use express.static(__dirname + '/public')

bundle = browserify(entry: __dirname + '/browser.coffee', watch: true)
bundle.use(fileify('levels', __dirname + '/levels', extension: '.txt', watch: true))
server.use(bundle)

server.use express.bodyParser()

server.get /^\/(\d+)?$/, (req, res) ->
  res.render('game.ejs')

server.get '/README', (req, res) ->
  fs.readFile (__dirname + '/README'), (err, data) ->
    res.render('readme.ejs', readme: data.toString())

port = process.env.PORT || 3000
server.listen(port)
console.log "Listening on port #{port}"

