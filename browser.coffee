Game   = require './src/game'
Levels = require.call(this, 'levels')

levelNumber = null
loadNextLevel = null
game        = null

loadLevel = (text) ->
  game = new Game(text)
  render()

loadLevelNumber = (n) ->
  levelNumber = n
  loadLevel(Levels["#{levelNumber}.txt"])

loadLevelFromPath = ->
  n = Number(location.pathname[1..-1])
  n = 0 unless n > 0
  loadLevelNumber(n)

render = ->
  pre = $('<pre/>').text(game.render())
  $('#level').empty().append(pre)

handleInput = (event) ->
  return unless $("#level:visible").length > 0

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
    loadNextLevel()
  else
    render()

setupEditor = ->
  $("#player").hide()

  loadNextLevel = ->
    text = $("#editor textarea").attr('value')
    at_count = text.match(/@/g)?.length

    if at_count == 1
      loadLevel(text)
      $("#editor").hide()
      $("#player").show()
    else if typeof at_count == 'undefined'
      alert "No `@' found - you need to place one in order to play!"
    else
      alert "Multiple `@'s found - you need to place exactly one in order to play!"

  $("#play button").click(loadNextLevel)

  options = []

  for filename, text of Levels
    number = filename.match(/\d+/)[0]
    options.push(number: number, html: "<option value='#{filename}'>#{number}</option>")

  $("#load select").html options.sort((o) -> o.number).map((o) -> o.html).join("")

  $("#load button").click ->
    filename = $("#load select").attr('value')
    $("#editor textarea").attr('value', Levels[filename])

  $("#player button").click ->
    $("#player").hide()
    $("#editor").show()

setupGame = ->
  loadNextLevel = ->
    loadLevelNumber(levelNumber+1)
    window.history.pushState(null, null, levelNumber.toString())

  $(window).bind('popstate', loadLevelFromPath)
  loadLevelFromPath()

$(window).bind('keydown', handleInput)

$ ->
  if $("#editor").length > 0
    setupEditor()
  else if $("#game").length > 0
    setupGame()


