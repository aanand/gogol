# util = require 'util'

Iterators =
  '▴': (game, newBoard, x, y) ->
    if game.at(x, y-1) == ' '
      newBoard[y-1][x] = '▴'
      newBoard[y][x] = '│'

module.exports = Iterators
