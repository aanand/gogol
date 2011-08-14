# util = require 'util'

Iterators = require './iterators'

class Game
  wallChars:
    '◾───' +
    '│┌┐┬' +
    '│└┘┴' +
    '│├┤┼'

  constructor: (levelText) ->
    @history = []

    @board       = []
    @boardWidth  = 0
    @boardHeight = 0

    for line in levelText.split("\n")
      line = line.replace /\s+$/, '' # remove trailing whitespace
      continue if line == ''

      row = []

      y = @boardHeight

      for x in [0..line.length-1]
        char = line[x]

        if char == '@'
          @playerX = x
          @playerY = y
          row.push(' ')
        else if @wallChars.indexOf(char) != -1
          row.push('#')
        else
          row.push(char)

      @boardHeight += 1
      @boardWidth = Math.max(@boardWidth, row.length)
      @board.push(row)

    unless @playerX? and @playerY?
      throw "No player found in level text"

  render: ->
    output = @copyBoard()
    output[@playerY][@playerX] = '@'

    for y in [0...@boardHeight]
      for x in [0...@boardWidth]
        if output[y][x] == '#'
          wallCharIndex = 0
          rldu = [[+1, 0], [-1, 0], [0, +1], [0, -1]]

          for i in [0..3]
            v = rldu[i]
            if @at(x+v[0], y+v[1]) == '#'
              wallCharIndex += (1 << i)

          output[y][x] = @wallChars[wallCharIndex]

    lines = output.map((row) -> row.join(''))
    lines.join('\n') + '\n'

  update: (input) ->
    if input == 'z'
      @rewind()
      false
    else
      @advance(input)

  advance: (input) ->
    @history.push [@copyBoard(), @playerX, @playerY]
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

    if 0 <= newPlayerX < @boardWidth and 0 <= newPlayerY < @boardHeight
      switch @at(newPlayerX, newPlayerY)
        when ' '
          @playerX = newPlayerX
          @playerY = newPlayerY
        when '█'
          return true

    false

  rewind: ->
    [@board, @playerX, @playerY] = @history.pop() if @history.length

  at: (x, y) ->
    if @board[y]
      @board[y][x] ? null
    else
      null

  iterateBoard: ->
    newBoard = @emptyBoard()

    for char, processor of Iterators
      for y in [0...@boardHeight]
        for x in [0...@boardWidth]
          if @at(x, y) == char
            processor(this, newBoard, x, y)

    for y in [0...@boardHeight]
      for x in [0...@boardWidth]
        newBoard[y][x] ||= @board[y][x]

    @board = newBoard

  copyBoard: ->
    @board.map (row) ->
      row.map (char) -> char

  emptyBoard: ->
    @board.map (row) ->
      row.map -> null

module.exports = Game

