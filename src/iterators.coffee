# util = require 'util'

Iterators = {}

extender = (dx, dy, extenderChar) ->
  Iterators[extenderChar] = (game, newBoard, x, y) ->
    newBoard[y][x] = '#'

    if game.at(x+dx, y+dy) == ' '
      newBoard[y+dy][x+dx] = extenderChar

extender(-1, 0, '╺')
extender(+1, 0, '╸')
extender(0, -1, '╻')
extender(0, +1, '╹')

module.exports = Iterators
