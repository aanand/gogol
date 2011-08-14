# util = require 'util'

Iterators = {}

extender = (dx, dy, extenderChar) ->
  Iterators[extenderChar] = (x, y, oldBoard, newBoard) ->
    newBoard.put(x, y, '#')

    if oldBoard.get(x+dx, y+dy) == ' '
      newBoard.put(x+dx, y+dy, extenderChar)

extender(-1, 0, '╺')
extender(+1, 0, '╸')
extender(0, -1, '╻')
extender(0, +1, '╹')

module.exports = Iterators
