# util = require 'util'

Board     = require './board'
Iterators = require './iterators'

class Game
  wallChars:
    '◾───' +
    '│┌┐┬' +
    '│└┘┴' +
    '│├┤┼'

  constructor: (levelText) ->
    @history = []
    @board = new Board()

    y = 0

    for line in levelText.split("\n")
      line = line.replace /\s+$/, '' # remove trailing whitespace
      continue if line == ''

      for x in [0...line.length]
        charIn  = line[x]
        charOut = charIn

        if charIn == '@'
          @playerX = x
          @playerY = y
          charOut = ' '
        else if @wallChars.indexOf(charIn) != -1
          charOut = '#'

        @board.put(x, y, charOut)

      y += 1

    unless @playerX? and @playerY?
      throw "No player found in level text"

  render: ->
    output = @board.copy()
    output.put(@playerX, @playerY, '@')

    @board.forEachCell (x, y, char) =>
      if char == '#'
        wallCharIndex = 0
        rldu = [[+1, 0], [-1, 0], [0, +1], [0, -1]]

        for i in [0..3]
          v = rldu[i]
          if @board.get(x+v[0], y+v[1]) == '#'
            wallCharIndex += (1 << i)

        output.put(x, y, @wallChars[wallCharIndex])

    lines = output.rows.map((row) -> row.join(''))
    lines.join('\n') + '\n'

  update: (input) ->
    if input == 'z'
      @rewind()
      false
    else
      @advance(input)

  advance: (input) ->
    @history.push [@board.copy(), @playerX, @playerY]
    @iterateBoard()

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

    switch @board.get(newPlayerX, newPlayerY)
      when ' '
        @playerX = newPlayerX
        @playerY = newPlayerY
      when '█'
        return true

    false

  rewind: ->
    [@board, @playerX, @playerY] = @history.pop() if @history.length

  iterateBoard: ->
    newBoard = @board.copy()

    for iChar, processor of Iterators
      @board.forEachCell (x, y, char) =>
        if char == iChar
          processor(x, y, @board, newBoard)

    @board = newBoard

module.exports = Game

