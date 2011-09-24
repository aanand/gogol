# util = require 'util'

Board  = require './board'
Pieces = require './pieces'

class Game
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
          @board.putPlayer(x, y)
          charOut = ' '

        @board.put(x, y, charOut)

      y += 1

    unless @board.hasPlayer()
      throw "No player found in level text"

  render: (options) ->
    output = @board.render(options)

    lines = output.map((row) -> row.join(''))
    lines.join('\n') + '\n'

  update: (input) ->
    if input == 'z'
      @rewind()
      false
    else
      @advance(input)

  advance: (input) ->
    newBoard   = @board.copy()
    newPlayerX = @board.playerX
    newPlayerY = @board.playerY
    move       = true

    switch input
      when 'up'
        newPlayerY -= 1
      when 'down'
        newPlayerY += 1
      when 'right'
        newPlayerX += 1
      when 'left'
        newPlayerX -= 1
      else
        move = false

    if move
      piece = @board.getPiece(newPlayerX, newPlayerY)

      if piece.endsLevel
        return true

      if piece.passable
        if piece.onEnter?
          piece.onEnter(newPlayerX, newPlayerY, newBoard)

        newBoard.putPlayer(newPlayerX, newPlayerY)

    newBoard = @iterate(newBoard)

    unless newBoard.equals(@board)
      @history.push(@board.copy())
      @board = newBoard

    false

  rewind: ->
    @board = @history.pop() if @history.length

  iterate: (oldBoard) ->
    newBoard = oldBoard.copy()

    for pChar, piece of Pieces
      if piece.iterate?
        oldBoard.forEachCell (x, y, char) =>
          if char == pChar
            piece.iterate(x, y, oldBoard, newBoard)

    newBoard

module.exports = Game

