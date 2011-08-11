util = require 'util'

class Game
  constructor: (levelText) ->
    @board       = []
    @boardWidth  = 0
    @boardHeight = 0

    for line in levelText.split("\n")
      line = line.replace /\s+$/, '' # remove trailing whitespace
      continue if line == ''

      row = []

      y = @boardHeight

      for x in [0..line.length-1]
        if line[x] == 'o'
          @playerX = x
          @playerY = y
          row.push(' ')
        else
          row.push(line[x])

      @boardHeight += 1
      @boardWidth = Math.max(@boardWidth, row.length)
      @board.push(row)

    unless @playerX? and @playerY?
      throw "No player found in level text"

  render: ->
    output = @board.map((row) -> row.map((char) -> char))
    output[@playerY][@playerX] = 'o'
    lines = output.map((row) -> row.join(''))
    lines.join('\n') + '\n'

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

    @playerX = Math.max(0, Math.min(@boardWidth-1, @playerX))
    @playerY = Math.max(0, Math.min(@boardHeight-1, @playerY))

module.exports = Game

