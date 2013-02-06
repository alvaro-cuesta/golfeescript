# TODO
#  coerce
#  rest of builtins
#  check with golfscript output
#  lb for arrays should decrement with pops
#  state kinda sucks (crappy references!)

coffee = require 'coffee-script'

DEBUG = true

log = ->
  console.log.apply this, arguments if DEBUG

REGEX = /[a-zA-Z_][a-zA-Z0-9_]*|'(?:\\.|[^'])*'?|"(?:\\.|[^"])*"?|-?[0-9]+|#[^\n\r]*|./gm #'
BUILTINS =
  '~': ->
    a = @stack.pop()

    switch typeOf a
      when 'int' then @stack.push ~a
      when 'string' then makeBlock(a) @stack, @variables
      when 'block' then a @stack, @variables
      when 'array' then @stack.push e for e in a

  '`': ->
    @stack.push toString @stack.pop()

  '!': ->
    a = @stack.pop()

    val = switch typeOf a
      when 'int' then val = a
      when 'block' then a.code.length
      else a.length

    @stack.push if not val then 1 else 0

  '@': ->
    [a, b, c] = [@stack.pop(), @stack.pop(), @stack.pop()]

    @stack.push b
    @stack.push a
    @stack.push c

  '$': ->
    a = @stack.pop()

    @stack.push switch typeOf a
      when 'int' then @stack[@stack.length - a - 1]
      when 'array' then a.sort()
      when 'string' then a.split('').sort().join()
      when 'block' then @stack.pop().sort a

  '+': ->
    a = @stack.pop()
    @stack.push @stack.pop() + a

  '-': ->
    a = @stack.pop()
    @stack.push @stack.pop() + a

  '[': ->
    @lb.push @stack.length

  ']': ->
    size = @lb.pop()
    array = @stack[size..]
    @stack = if size then @stack[..size] else []
    @stack.push array

typeOf = (e) ->
  switch Object.prototype.toString.call e
    when '[object Number]' then 'int'
    when '[object String]' then 'string'
    when '[object Function]' then 'block'
    when '[object Array]' then 'array'
    else throw "Unknown type for #{e}"

toString = (e) ->
  switch typeOf e
    when 'int' then e.toString()
    when 'string' then '"' + e.toString() + '"'
    when 'block' then e.toString()
    when 'array'
      elements = (toString x for x in e)
      '[' + elements.join(' ') + ']'
    else throw "Unknown string representation for #{e}"

makeBlock = (code) ->

  parsed = switch typeOf code
    when 'string' then golfee.parse code
    when 'array' then code
    else throw "Cannot parse #{code}"

  # Return the block
  block = (stack, variables) ->

    state =
      variables: variables
      stack: stack
      lb: []

    log 'PARSED:', parsed[..]

    while parsed[0]?
      token = parsed.shift()
      log 'TOKEN:', token

      # Tokens built in syntax
      if token == '{'
        end = parsed.indexOf '}'
        stack.push makeBlock(parsed[0...end])
        parsed = parsed[end+1..]
      else if token == ':'

      else  # Not built in syntax
        val = variables[token]

        log 'VAL:', val

        # Is it a variable
        if val?
          log 'FOUND'

          # Execute if it's a block
          if typeOf(val) == 'block'
            val.apply state
          else
            stack.push val
        else  # Not a variable
          log 'NOT_FOUND'
          b = eval token
          stack.push b if b?

      log 'STACK:', stack

    log 'END STACK:', stack

  block.code = parsed.join ''
  block.toString = -> '{' + block.code + '}'

  block

module.exports = golfee =
  REGEX: REGEX
  BUILTINS: BUILTINS

  makeBlock: makeBlock
  typeOf: typeOf
  toString: toString

  parse: (code) ->
    code.match golfee.REGEX
  run: (code, stack = [], variables = BUILTINS) ->  # TODO: copy!
    makeBlock(code) stack, variables