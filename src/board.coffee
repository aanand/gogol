Pieces = require('./pieces')

class Board
  constructor: (rows) ->
    @rows = rows ? []

  get: (x, y) ->
    if @rows[y]
      @rows[y][x] ? null
    else
      null

  getPiece: (x, y) ->
    char = @get(x, y)
    char and Pieces.get(char)

  put: (x, y, char) ->
    if y >= @rows.length
      for i in [@rows.length..y]
        @rows[i] = []

    row = @rows[y]

    if x >= row.length
      for i in [row.length..x]
        row[i] = null
    
    row[x] = char

  putPlayer: (x, y) ->
    @playerX = x
    @playerY = y

  hasPlayer: ->
    @playerX? and @playerY?

  search: (needle) ->
    locations = []

    @forEachCell (x, y, char) ->
      if char == needle
        locations.push [x,y]

    locations

  forEachCell: (callback) ->
    for y in [0...@rows.length]
      row = @rows[y]

      for x in [0...row.length]
        callback(x, y, row[x])

  copy: ->
    rowsCopy = @rows.map (row) ->
      row.map (char) -> char

    newBoard = new Board(rowsCopy)
    newBoard.putPlayer(@playerX, @playerY)
    newBoard

  equals: (board) ->
    answer = (@playerX == board.playerX and @playerY == board.playerY)

    @forEachCell (x, y, char) ->
      answer = false unless board.get(x, y) == char

    answer

module.exports = Board
