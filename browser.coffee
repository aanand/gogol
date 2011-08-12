Game   = require './src/game'
Levels = require.call(this, 'levels')

levelNumber = null
game        = null

loadLevel = ->
  game = new Game(Levels["#{levelNumber}.txt"])

render = ->
  document.body.innerHTML = ""
  pre = document.createElement('pre')
  pre.innerText = game.render()
  document.body.appendChild(pre)

levelNumber = 0
loadLevel()

window.addEventListener 'keydown', (event) ->
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
    levelNumber += 1
    loadLevel()

  render()

render()

