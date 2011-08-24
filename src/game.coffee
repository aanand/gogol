# util = require 'util'

Board  = require './board'
Pieces = require './pieces'

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

      for x in [0...line.length]
        charIn  = line[x]
        charOut = charIn

        if charIn == '@'
          @playerX = x
          @playerY = y
          charOut = ' '

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
          if @isWallChar(@board.get(x+v[0], y+v[1]))
            wallCharIndex += (1 << i)

        output.put(x, y, @wallChars[wallCharIndex])

    lines = output.rows.map((row) -> row.join(''))
    lines.join('\n') + '\n'

  isWallChar: (char) ->
    char == '#' or @wallChars.indexOf(char) != -1

  update: (input) ->
    if input == 'z'
      @rewind()
      false
    else
      @advance(input)

  advance: (input) ->
    newBoard   = @iterate()
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

    char  = @board.get(newPlayerX, newPlayerY)
    piece = Pieces.get(char)

    if piece.endsLevel
      return true

    if piece.passable
      if piece.onEnter?
        piece.onEnter(newPlayerX, newPlayerY, newBoard)
    else
      newPlayerX = @playerX
      newPlayerY = @playerY

    unless newBoard.equals(@board) and newPlayerX == @playerX and newPlayerY == @playerY
      @history.push [@board.copy(), @playerX, @playerY]

      @board   = newBoard
      @playerX = newPlayerX
      @playerY = newPlayerY

    false

  rewind: ->
    [@board, @playerX, @playerY] = @history.pop() if @history.length

  iterate: ->
    newBoard = @board.copy()

    for pChar, piece of Pieces
      if piece.iterate?
        @board.forEachCell (x, y, char) =>
          if char == pChar
            piece.iterate(x, y, @board, newBoard)

    newBoard

module.exports = Game

