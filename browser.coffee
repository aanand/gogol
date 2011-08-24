Game   = require './src/game'
Levels = require.call(this, 'levels')

levelNumber = null
game        = null

loadLevel = (n) ->
  levelNumber = n
  game        = new Game(Levels["#{levelNumber}.txt"])

  render()

loadLevelFromPath = ->
  n = Number(location.pathname[1..-1])
  n = 0 unless n > 0
  loadLevel(n)

render = ->
  pre = $('<pre/>').text(game.render())
  $('#game').empty().append(pre)

handleInput = (event) ->
  input = switch event.keyCode
    when 37
      'left'
    when 38
      'up'
    when 39
      'right'
    when 40
      'down'
    when 90
      'z'
    else
      null

  return unless input?

  if game.update(input)
    loadLevel(levelNumber+1)
    window.history.pushState(null, null, levelNumber.toString())
  else
    render()

$(window)
  .bind('keydown', handleInput)
  .bind('popstate', loadLevelFromPath)

$ ->
  if $("#game").length > 0
    loadLevelFromPath()


