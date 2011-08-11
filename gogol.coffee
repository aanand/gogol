util = require 'util'
tty  = require 'tty'

class Game
  constructor: (options) ->
    @screenWidth  = options.screenWidth
    @screenHeight = options.screenHeight
    @playerX      = options.playerX || 1
    @playerY      = options.playerY || 1

  render: ->
    output = ""

    for y in [0..@screenHeight-1]
      for x in [0..@screenWidth-1]
        char = if x == @playerX and y == @playerY
          "o"
        else if x == 0 or x == @screenWidth-1 or y == 0 or y == @screenHeight-1
          "#"
        else
          " "
        
        output += char

      output += "\n"

    output

  update: (input) ->
    switch input
      when 'up'
        @playerY -= 1
      when 'down'
        @playerY += 1
      when 'right'
        @playerX += 1
      when 'left'
        @playerX -= 1

game = new Game(screenWidth: 40, screenHeight: 10, playerX: 1, playerY: 1)

render = ->
  process.stdout.write game.render()
  process.stdout.write "\033[" + game.screenWidth  + "D"
  process.stdout.write "\033[" + game.screenHeight + "A"

tty.setRawMode(true)

process.stdin.on 'data', (chunk) ->
  switch chunk.toString()
    when '\u0003' # ctrl-C
      process.exit()
    when '\u001b[A'
      game.update 'up'
    when '\u001b[B'
      game.update 'down'
    when '\u001b[C'
      game.update 'right'
    when '\u001b[D'
      game.update 'left'

  render()

render()
process.stdin.resume()
