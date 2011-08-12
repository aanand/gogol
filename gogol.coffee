util = require 'util'
tty  = require 'tty'
path = require 'path'
fs   = require 'fs'

Game = require './src/game'

levelNumber = null
game        = null

loadLevel = ->
  levelPath = "levels/#{levelNumber}.txt"

  unless path.existsSync(levelPath)
    console.log "Could not find level #{util.inspect(levelNumber)}"
    process.exit(-1)

  levelText = fs.readFileSync(levelPath).toString()
  game = new Game(levelText)

render = ->
  process.stdout.write("\033[f")
  process.stdout.write("\033[2J")
  process.stdout.write game.render()

levelNumber = Number(process.argv[2] || '0')
loadLevel()

tty.setRawMode(true)

process.stdin.on 'keypress', (chunk, key) ->
  switch key.name
    when 'up', 'down', 'left', 'right', 'z'
      if game.update(key.name)
        levelNumber += 1
        loadLevel()

      render()
    when 'escape', 'q'
      process.exit()
    when 'c', 'd'
      process.exit() if key.ctrl

render()
process.stdin.resume()

