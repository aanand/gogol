util = require 'util'
tty  = require 'tty'
path = require 'path'
fs   = require 'fs'

Game = require './src/game'

levelName = process.argv[2] || '0'
levelPath = levelName

unless path.existsSync(levelPath)
  levelPath = "levels/#{levelPath}.txt"

unless path.existsSync(levelPath)
  console.log "Could not find level #{util.inspect(levelName)}"
  process.exit(-1)

levelText = fs.readFileSync(levelPath).toString()

game = new Game(levelText)

tty.setRawMode(true)

process.stdin.on 'keypress', (chunk, key) ->
  switch key.name
    when 'up', 'down', 'left', 'right', 'z'
      game.update(key.name)
    when 'escape', 'q'
      process.exit()
    when 'c', 'd'
      process.exit() if key.ctrl

  process.stdout.write "\033[" + game.boardWidth  + "D"
  process.stdout.write "\033[" + game.boardHeight + "A"
  process.stdout.write game.render()

process.stdout.write game.render()
process.stdin.resume()
