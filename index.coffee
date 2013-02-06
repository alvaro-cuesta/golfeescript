# TODO
#  rest of builtins
#  check with golfscript output
#  lb for arrays should decrement with pops
#  state kinda sucks (crappy references!)
#  :
#  do not console.log prints, put in buffer

coffee = require 'coffee-script'

# DEBUG #

DEBUG = true
log = -> console.log.apply this, arguments if DEBUG


# LANGUAGE DEFINITIONS #

REGEX = /[a-zA-Z_][a-zA-Z0-9_]*|'(?:\\.|[^'])*'?|"(?:\\.|[^"])*"?|-?[0-9]+|#[^\n\r]*|./gm #'

parse = (code) ->
  code.match REGEX

typeOf = (x) ->
  switch Object.prototype.toString.call x
    when '[object Number]' then 'int'
    when '[object String]' then 'string'
    when '[object Function]' then 'block'
    when '[object Array]' then 'array'
    else throw "Unknown type for #{x}"

toString = (x) ->
  switch typeOf x
    when 'int' then x.toString()
    when 'string' then '"' + x.toString() + '"'
    when 'block' then '{' + x.code + '}'
    when 'array' then '[' + (toString e for e in x).join(' ') + ']'
    else throw "Unknown string representation for #{x}"

coerce = (a, b) ->
  switch typeOf a
    when 'block' then return [a, makeBlock b]
    when 'string' then return [a, '' + b] if typeOf(b) != 'block'
    when 'array' then switch typeOf b
      when 'array' then return [a, b]
      when 'int' then return [a, [b]]
    when 'int' then return [a, b] if typeOf(b) == 'int'

  coerce(b, a).reverse()

makeBlock = (code) ->

  parsed = parse switch typeOf code
    when 'int' then code.toString()
    when 'string' then code
    when 'array' then code
    when 'block' then code.code
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
        name = parsed.shift()
        state.variables[name] = state.stack[state.stack.length - 1]
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

    console.log stack.join('') if stack?

  block.code = parsed.join ''

  block


# BUILT IN VARIABLES #

BUILTINS =  # in order as they appear on http://www.golfscript.com/golfscript/builtin.html
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

    @stack.push ~~ not switch typeOf a
      when 'int' then a
      when 'block' then a.code.length
      else a.length

  '@': ->
    [a, b, c] = [@stack.pop(), @stack.pop(), @stack.pop()]

    @stack.push x for x in [b, a ,c]

  '$': ->
    a = @stack.pop()

    @stack.push switch typeOf a
      when 'int' then @stack[@stack.length - a - 1]
      when 'array' then a.sort()
      when 'string' then a.split('').sort().join('')
      when 'block' then throw '$(block) not implemented'

  '+': ->
    [b, a] = coerce @stack.pop(), @stack.pop()

    @stack.push switch typeOf a
      when 'array' then a.concat b
      when 'block' then makeBlock a.code + b.code
      else a + b

  '-': ->
    [b, a] = coerce @stack.pop(), @stack.pop()

    @stack.push switch typeOf a
      when 'int' then a - b
      else throw "- (#{typeOf a}) not implemented"

  '*': ->
    throw '* not implemented'

  '/': ->
    throw '/ not implemented'

  '%': ->
    throw '% not implemented'

  '|': ->
    throw '| not implemented'

  '&': ->
    throw '& not implemented'

  '^': ->
    throw '^ not implemented'

  '[': ->
    @lb.push @stack.length

  ']': ->
    size = @lb.pop()
    array = @stack[size..]
    @stack = if size then @stack[..size] else []
    @stack.push array

  '\\': ->
    @stack.push x for x in [@stack.pop(), @stack.pop()]

  ';': ->
    @stack.pop()

  '<': ->
    throw '< not implemented'

  '>': ->
    throw '> not implemented'

  '=': ->
    throw '= not implemented'

  ',': ->
    a = @stack.pop()

    @stack.push switch typeOf a
      when 'int' then [0...a]
      when 'array' then a.length
      when 'string' then throw ", is not defined for strings"
      when 'block' then throw ", (block) not implemented"

  '.': ->
    @stack.push @stack[@stack.length - 1]

  '?': ->
    throw '? not implemented'

  '(': ->
    a = @stack.pop()

    @stack.push switch typeOf a
      when 'int' then a - 1
      when 'array' then a.shift(); a
      else "( is not defined for #{typeOf a}"

  ')': ->
    a = @stack.pop()

    @stack.push switch typeOf a
      when 'int' then a + 1
      when 'array' then a.pop(); a
      else ") is not defined for #{typeOf a}"

  'and': ->
    throw 'and not implemented'

  'or': ->
    throw 'or not implemented'

  'xor': ->
    throw 'xor not implemented'

  'print': ->
    console.log toString

  'p': makeBlock '`puts'

  'n': '\n'

  'puts': makeBlock 'print n print'

  # TODO: what about neg and such
  'rand': ->
    @stack.push ~~ Math.random() * @stack.pop()

  'do': ->
    throw 'do not implemented'

  'while': ->
    throw 'while not implemented'

  'until': ->
    throw 'until not implemented'

  'if': ->
    throw 'if not implemented'

  'abs': ->
    a = @stack.pop()

    @stack.push switch typeOf a
      when 'int' then Math.abs a
      else "abs is not defined for #{typeOf a}"

  'zip': ->
    throw 'zip not implemented'

  'base': ->
    throw 'base not implemented'


# EXPORTS #

module.exports = golfee =
  REGEX: REGEX
  BUILTINS: BUILTINS

  parse: parse
  makeBlock: makeBlock
  typeOf: typeOf
  toString: toString
  coerce: coerce

  run: (code, stack = [], variables = BUILTINS) ->  # TODO: copy!
    makeBlock(code) stack, variables
