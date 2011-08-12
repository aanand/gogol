util = require 'util'

Iterators = require './iterators'

class Game
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
        if line[x] == '@'
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
    output = @copyBoard()
    output[@playerY][@playerX] = '@'
    lines = output.map((row) -> row.join(''))
    lines.join('\n') + '\n'

  update: (input) ->
    if input == 'z'
      @rewind()
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

    if 0 <= newPlayerX < @boardWidth and 0 <= newPlayerY < @boardHeight and @at(newPlayerX, newPlayerY) == ' '
      @playerX = newPlayerX
      @playerY = newPlayerY

  rewind: ->
    [@board, @playerX, @playerY] = @history.pop() if @history.length

  at: (x, y) -> @board[y][x]

  iterateBoard: ->
    newBoard = @board.map (row) ->
      row.map -> null

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

module.exports = Game

