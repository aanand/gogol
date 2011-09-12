Game   = require './src/game'
Levels = require.call(this, 'levels')

class Gogol extends Backbone.View
  initialize: =>
    if @$(".editor").length > 0
      new Editor(el: @$(".editor"))

    if @$(".adventure").length > 0
      new Adventure(el: @$(".adventure"))

class Adventure extends Backbone.View
  initialize: =>
    @levelNumber = null
    @player = new Player(el: @$(".player"))

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

class Editor extends Backbone.View
  initialize: =>
    @player = new Player(el: @$(".player"))
    @player.bind("levelComplete", @play)

    @populateLoadSelect()

    if LevelJSON?
      @level = new Level(LevelJSON)
      @setEditorText(@level.get('text'))
      @play()
    else
      @edit()

  events:
    "click .play button" : "checkAndPlay"
    "click .load button" : "load"
    "click button.edit"  : "edit"
    "click button.save"  : "save"

  play: (text) =>
    @player.loadLevel @getEditorText()
    @$(".edit-screen").hide()
    @$(".preview-screen").show()

  checkAndPlay: =>
    text = @getEditorText()
    at_count = text.match(/@/g)?.length

    if at_count == 1
      @play()
    else if typeof at_count == 'undefined'
      alert "No `@' found - you need to place one in order to play!"
    else
      alert "Multiple `@'s found - you need to place exactly one in order to play!"

  load: =>
    filename = @$(".load select").attr('value')
    @$("textarea").attr('value', Levels[filename])

  edit: =>
    @$(".preview-screen").hide()
    @$(".edit-screen").show()

  save: =>
    @$("#message").text("Saving...")
    attrs = { text: @getEditorText() }

    if @level?
      @level.save attrs,
        success: =>
          @$(".message").text("Level saved.")
          window.setTimeout (-> @$(".message").empty()), 3000
    else
      @level = new Level(attrs)

      @level.save {},
        success: =>
          window.location.href = "/levels/#{@level.id}"

  populateLoadSelect: =>
    options = []

    for filename, text of Levels
      number = filename.match(/\d+/)[0]
      options.push(number: number, html: "<option value='#{filename}'>#{number}</option>")

    @$(".load select").html options.sort((o) -> o.number).map((o) -> o.html).join("")

  getEditorText:        => @$("textarea").attr('value')
  setEditorText: (text) => @$("textarea").attr('value', text)

class Level extends Backbone.Model
  urlRoot: "/levels"

  initialize: (options) =>
    @setId()
    @bind("change:_id", @setId)

  setId: =>
    if id = @get('_id')
      @id = id
      @unset('_id')

window.App = new Gogol(el: $("#content"))
