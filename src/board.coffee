class Board
  constructor: (rows) ->
    @rows = rows ? []

  get: (x, y) ->
    if @rows[y]
      @rows[y][x] ? null
    else
      null

  put: (x, y, char) ->
    if y >= @rows.length
      for i in [@rows.length..y]
        @rows[i] = []

    row = @rows[y]

    if x >= row.length
      for i in [row.length..x]
        row[i] = null
    
    row[x] = char

  forEachCell: (callback) ->
    for y in [0...@rows.length]
      row = @rows[y]

      for x in [0...row.length]
        callback(x, y, row[x])

  copy: ->
    rowsCopy = @rows.map (row) ->
      row.map (char) -> char

    new Board(rowsCopy)

  equals: (board) ->
    answer = true

    @forEachCell (x, y, char) ->
      answer = false unless board.get(x, y) == char

    answer

module.exports = Board
