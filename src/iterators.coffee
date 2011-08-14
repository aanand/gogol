# util = require 'util'

Iterators = {}

extender = (dx, dy, wallChar, extenderChar) ->
  Iterators[extenderChar] = (game, newBoard, x, y) ->
    if game.at(x+dx, y+dy) == ' '
      newBoard[y+dy][x+dx] = extenderChar
      newBoard[y][x] = wallChar

extender(-1, 0, '─', '╾')
extender(+1, 0, '─', '╼')
extender(0, -1, '│', '╿')
extender(0, +1, '│', '╽')

module.exports = Iterators
