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
    newPlayerX = @playerX
    newPlayerY = @playerY

    switch input
      when 'up'
        newPlayerY -= 1
      when 'down'
        newPlayerY += 1
      when 'right'
        newPlayerX += 1
      when 'left'
        newPlayerX -= 1

    return unless 0 <= newPlayerX < @boardWidth
    return unless 0 <= newPlayerY < @boardHeight

    @playerX = newPlayerX
    @playerY = newPlayerY

module.exports = Game

