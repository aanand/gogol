Pieces = require('./pieces')

class Board
  wallChars:
    '◾───' +
    '│┌┐┬' +
    '│└┘┴' +
    '│├┤┼'

  autoWallChars:
    '#': 'rldu'
    '=': 'rl'
    'I': 'du'

  constructor: (rows) ->
    @rows = rows ? []

  get: (x, y) ->
    if x == @playerX and y == @playerY
      '@'
    else
      @getRaw(x, y)

  getRaw: (x, y) ->
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

  render: ->
    rendered = @copy()

    @forEachCell (x, y, char) =>
      if @autoWallChars[char]?
        @renderAutoWallChar(x, y, char, rendered)

    [0...@rows.length].map (y) =>
      row = @rows[y]
      [0...row.length].map (x) ->
        rendered.get(x, y)

  renderAutoWallChar: (x, y, charHere, output) ->
    directions = @autoWallChars[charHere]
    wallCharIndex = 0
    rldu = [[+1, 0], [-1, 0], [0, +1], [0, -1]]

    for i in [0..3]
      direction = 'rldu'[i]
      continue if directions.indexOf(direction) == -1

      delta     = rldu[i]
      charThere = @get(x + delta[0], y + delta[1])

      if charThere == charHere or @wallChars.indexOf(charThere) >= 0
        wallCharIndex += (1 << i)

    charToPut = @wallChars[wallCharIndex]
    output.put(x, y, charToPut)

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
      answer = false unless board.getRaw(x, y) == char

    answer

module.exports = Board
