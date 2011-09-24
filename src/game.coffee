# util = require 'util'

Board  = require './board'
Pieces = require './pieces'

class Game
  wallChars:
    '◾───' +
    '│┌┐┬' +
    '│└┘┴' +
    '│├┤┼'

  autoWallChars:
    '#': 'rldu'
    '=': 'rl'
    'I': 'du'

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

  render: ->
    output = @board.copy()
    output.put(@board.playerX, @board.playerY, '@')

    @board.forEachCell (x, y, char) =>
      @transformAutoWallChar(output, x, y)

    lines = output.rows.map((row) -> row.join(''))
    lines.join('\n') + '\n'

  transformAutoWallChar: (output, x, y) ->
    charHere   = @board.get(x, y)
    directions = @autoWallChars[charHere]

    return unless directions?

    wallCharIndex = 0
    rldu = [[+1, 0], [-1, 0], [0, +1], [0, -1]]

    for i in [0..3]
      direction = 'rldu'[i]
      continue if directions.indexOf(direction) == -1

      delta     = rldu[i]
      charThere = @board.get(x + delta[0], y + delta[1])

      if charThere == charHere or @wallChars.indexOf(charThere) >= 0
        wallCharIndex += (1 << i)

    charToPut = @wallChars[wallCharIndex]
    output.put(x, y, charToPut)

  update: (input) ->
    if input == 'z'
      @rewind()
      false
    else
      @advance(input)

  advance: (input) ->
    newBoard   = @iterate()
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
      char  = @board.get(newPlayerX, newPlayerY)
      piece = Pieces.get(char)

      if piece.endsLevel
        return true

      if piece.passable
        if piece.onEnter?
          piece.onEnter(newPlayerX, newPlayerY, newBoard)

        newBoard.putPlayer(newPlayerX, newPlayerY)

    unless newBoard.equals(@board)
      @history.push(@board.copy())
      @board = newBoard

    false

  rewind: ->
    @board = @history.pop() if @history.length

  iterate: ->
    newBoard = @board.copy()

    for pChar, piece of Pieces
      if piece.iterate?
        @board.forEachCell (x, y, char) =>
          if char == pChar
            piece.iterate(x, y, @board, newBoard)

    newBoard

module.exports = Game

