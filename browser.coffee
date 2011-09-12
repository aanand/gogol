Game   = require './src/game'
Levels = require.call(this, 'levels')

class Gogol extends Backbone.View
  initialize: =>
    # if @$("#editor").length > 0
      # new Editor(el: @$("#editor"))

    if @$("#game").length > 0
      new Adventure(el: @$("#game"))

class Adventure extends Backbone.View
  initialize: =>
    @levelNumber = null
    @player = new Player(el: @$("#level"))

    @player.bind "levelComplete", =>
      @loadLevelNumber(@levelNumber+1)
      window.history.pushState(null, null, @levelNumber.toString())

    $(window).bind('popstate', @loadLevelFromPath)
    @loadLevelFromPath()

  loadLevelFromPath: =>
    n = Number(location.pathname[1..-1])
    n = 0 unless n > 0
    @loadLevelNumber(n)

  loadLevelNumber: (n) =>
    @levelNumber = n
    @player.loadLevel(Levels["#{@levelNumber}.txt"])

class Player extends Backbone.View
  initialize: =>
    $(window).keydown (event) =>
      return unless $(@el).is(":visible")

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

      if @game.update(input)
        @trigger("levelComplete")
      else
        @render()

  loadLevel: (text) =>
    @game = new Game(text)
    @render()

  render: ->
    pre = $('<pre/>').text(@game.render())
    $(@el).empty().append(pre)
    this

setupEditor = ->
  getEditorText =        -> $("#editor textarea").attr('value')
  setEditorText = (text) -> $("#editor textarea").attr('value', text)

  playLevel = (text) ->
    loadLevel getEditorText()
    $("#editor").hide()
    $("#player").show()

  loadNextLevel = ->
    text = getEditorText()
    at_count = text.match(/@/g)?.length

    if at_count == 1
      playLevel()
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

  $("#edit").click ->
    $("#player").hide()
    $("#editor").show()

  $("#save").click ->
    $("#message").text("Saving...")

    if Level?
      $.post "/levels/#{Level._id}", {_method: "put", text: getEditorText()}, (result) ->
        $("#message").text("Level saved.")
        window.setTimeout (-> $("#message").empty()), 3000
    else
      $.post '/levels', {text: getEditorText()}, (level) ->
        window.location.href = "/levels/#{level._id}"

  if Level?
    setEditorText(Level.text)
    playLevel()
  else
    $("#player").hide()

window.App = new Gogol(el: $("#content"))
