util = require 'util'
tty  = require 'tty'

Game = require './src/game'

game = new Game(screenWidth: 40, screenHeight: 10, playerX: 1, playerY: 1)

render = ->
  process.stdout.write game.render()
  process.stdout.write "\033[" + game.screenWidth  + "D"
  process.stdout.write "\033[" + game.screenHeight + "A"

tty.setRawMode(true)

process.stdin.on 'keypress', (chunk, key) ->
  switch key.name
    when 'up', 'down', 'left', 'right'
      game.update(key.name)
    when 'escape', 'q'
      process.exit()
    when 'c', 'd'
      process.exit() if key.ctrl

  render()

render()
process.stdin.resume()
