# util = require 'util'

extender = (dx, dy, wallChar, extenderChar) ->
  (game, newBoard, x, y) ->
    if game.at(x+dx, y+dy) == ' '
      newBoard[y+dy][x+dx] = extenderChar
      newBoard[y][x] = wallChar

Iterators =
  '╾': extender(-1, 0, '─', '╾')
  '╼': extender(+1, 0, '─', '╼')
  '╿': extender(0, -1, '│', '╿')
  '╽': extender(0, +1, '│', '╽')

module.exports = Iterators
