fs   = require('fs')
util = require('util')

consumeWhitespace = (lines) ->
  while lines[0]?.match /^\s*$/
    lines.shift()

parseTest = (lines) ->
  test = {}

  consumeWhitespace(lines)

  return null unless lines.length > 0

  matchDescription = lines[0].match(/^#\s*(.*)$/)
  throw "expected line beginning with `#', got: #{lines[0]}" unless matchDescription
  test.description = matchDescription[1]
  lines.shift()

  consumeWhitespace(lines)

  test.start = ""

  while !lines[0].match(/^\s*\+\s*$/)
    test.start += lines.shift() + '\n'
  lines.shift()

  consumeWhitespace(lines)

  test.inputs = (input.replace(/^\s+|\s+$/g, '') for input in lines.shift().split(','))

  consumeWhitespace(lines)

  throw "expected line `=', got: #{lines[0]}" unless lines[0].match(/^\s*=\s*$/)
  lines.shift()

  consumeWhitespace(lines)

  test.finish = ""

  while !lines[0].match(/^\s*$/)
    test.finish += lines.shift() + '\n'
  lines.shift()

  test

suites = {}

for filename in fs.readdirSync(__dirname)
  match = filename.match /^(.*)\.txt$/

  if match
    testName = match[1]
    suites[testName] ||= []

    text  = fs.readFileSync("#{__dirname}/#{filename}").toString()
    lines = text.split('\n')

    loop
      try
        test = parseTest(lines)
        break unless test
        suites[testName].push(test)
      catch e
        console.log e.toString()

Game = require('../src/game')

makeTest = (test) ->
  ->
    game = new Game(test.start)
    game.renderAutoWalls = false

    for i in test.inputs
      game.update(i)

    expect('\n' + game.render(skipAutoWalls: true)).toEqual('\n' + test.finish)

for filename, tests of suites
  describe filename, ->
    for test in tests
      it test.description, makeTest(test)

