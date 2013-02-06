# CoffeeScript original builtins
# as shown on http://www.golfscript.com/golfscript/builtin.html

{typeOf, toString, coerce, makeBlock} = require './lang'

module.exports = BUILTINS = ->
  # Return a fresh copy for each call to avoid overwriting of symbols (object = reference)
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
#      when 'block' then @stack.pop().sort a

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

  # '*': ->
  #   [a, b] = [@stack.pop(), @stack.pop()]
  #   @stack.push switch typeOf a
  #     when 'int' then switch typeOf b
  #       when 'int' then a * b
  #       when 'string' then Array(a+1).join b
  #       when 'array' then [].concat b for x in [1..a]
  #       when 'block' then b @stack, @variables for x in [1..a]
  #         # TODO: same for reverse
  #     when 'string' then
  #     when 'array' then
  #     when 'block' then

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