express    = require('express')
browserify = require('browserify')
fileify    = require('fileify')
mongodb    = require('mongodb')
fs         = require('fs')

dbUrl = process.env.MONGOHQ_URL || mongodb.Db.DEFAULT_URL

ensureLevelCollection = (callback) ->
  mongodb.connect dbUrl, (err, db) ->
    throw err if err
    db.collection 'levels', (err, coll) ->
      throw err if err
      callback(db, coll)

insertLevel = (level, callback) ->
  ensureLevelCollection (db, coll) ->
    coll.insert level, (err, result) ->
      throw err if err
      callback(result[0])

fetchLevel = (id, callback) ->
  ensureLevelCollection (db, coll) ->
    coll.find(_id: id).toArray (err, result) ->
      throw err if err
      callback(result[0])

updateLevel = (id, attrs, callback) ->
  ensureLevelCollection (db, coll) ->
    coll.update {_id: id}, attrs, {}, (err) ->
      throw err if err
      callback()

fetchLevelOr404 = (req, res, callback) ->
  ensureLevelCollection (db, coll) ->
    id = new db.bson_serializer.ObjectID req.param('_id')

    fetchLevel id, (level) ->
      if level?
        callback(level)
      else
        res.send(404)

server = express.createServer()

server.use express.logger()
server.use express.static(__dirname + '/public')

bundle = browserify(entry: __dirname + '/browser.coffee', watch: true)
bundle.use(fileify('levels', __dirname + '/levels', extension: '.txt', watch: true))
server.use(bundle)

server.use express.bodyParser()
server.use express.methodOverride()

server.get /^\/(\d+)?$/, (req, res) ->
  res.render('adventure.ejs')

server.get '/README', (req, res) ->
  fs.readFile (__dirname + '/README'), (err, data) ->
    res.render('readme.ejs', readme: data.toString())

server.get '/editor', (req, res) ->
  res.render('editor.ejs', level: null)

server.post '/levels', (req, res) ->
  insertLevel {text: req.body.text}, (level) ->
    res.json level

server.get '/levels/:_id', (req, res) ->
  fetchLevelOr404 req, res, (level) ->
    res.render('editor.ejs', level: level)

server.put '/levels/:_id', (req, res) ->
  fetchLevelOr404 req, res, (level) ->
    updateLevel level._id, {text: req.body.text}, ->
      res.json {}

port = process.env.PORT || 3000
server.listen(port)
console.log "Listening on port #{port}"

