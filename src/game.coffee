class Game
  constructor: (options) ->
    @screenWidth  = options.screenWidth
    @screenHeight = options.screenHeight
    @playerX      = options.playerX || 1
    @playerY      = options.playerY || 1

  render: ->
    output = ""

    for y in [0..@screenHeight-1]
      for x in [0..@screenWidth-1]
        char = if x == @playerX and y == @playerY
          "o"
        else if x == 0 or x == @screenWidth-1 or y == 0 or y == @screenHeight-1
          "#"
        else
          " "
        
        output += char

      output += "\n"

    output

  update: (input) ->
    switch input
      when 'up'
        @playerY -= 1
      when 'down'
        @playerY += 1
      when 'right'
        @playerX += 1
      when 'left'
        @playerX -= 1

module.exports = Game

