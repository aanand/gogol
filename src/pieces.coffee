# util = require 'util'

Pieces =
  get: (char) ->
    this[char] ? this.default

  ' ':
    passable: true

  '█':
    endsLevel: true

  '?':
    passable: true

  '!':
    passable: false

  'x':
    passable: true
    onEnter: (x, y, board) ->
      qs = board.search('?')
      es = board.search('!')

      board.put(x, y, '!') for [x,y] in qs
      board.put(x, y, '?') for [x,y] in es

  default:
    wall: true

extender = (dx, dy, extenderChar) ->
  Pieces[extenderChar] =
    iterate: (x, y, oldBoard, newBoard) ->
      piece = oldBoard.getPiece(x+dx, y+dy)

      newBoard.put(x+dx, y+dy, extenderChar) if piece.passable

      if piece.passable or piece.wall
        wallChar = if dx == 0
          'I'
        else
          '='

        newBoard.put(x, y, wallChar)

extender(-1, 0, '<')
extender(+1, 0, '>')
extender(0, -1, '^')
extender(0, +1, 'v')

module.exports = Pieces
