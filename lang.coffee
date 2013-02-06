# DEBUGGING #

module.exports.log = log = -> console.log.apply this, arguments if DEBUG

module.exports.DEBUG = DEBUG = true


# LANGUAGE FUNCTIONS #

module.exports.REGEX = REGEX = /[a-zA-Z_][a-zA-Z0-9_]*|'(?:\\.|[^'])*'?|"(?:\\.|[^"])*"?|-?[0-9]+|#[^\n\r]*|./gm #'

module.exports.parse = parse = (code) ->
  code.match REGEX

module.exports.typeOf = typeOf = (x) ->
  switch Object.prototype.toString.call x
    when '[object Number]' then 'int'
    when '[object String]' then 'string'
    when '[object Function]' then 'block'
    when '[object Array]' then 'array'
    else throw "Unknown type for #{x}"

module.exports.toString = toString = (x) ->
  switch typeOf x
    when 'int' then x.toString()
    when 'string' then '"' + x.toString() + '"'
    when 'block' then '{' + x.code + '}'
    when 'array' then '[' + (toString e for e in x).join(' ') + ']'
    else throw "Unknown string representation for #{x}"

module.exports.coerce = coerce = (a, b) ->
  switch typeOf a
    when 'block' then return [a, makeBlock b]
    when 'string' then return [a, '' + b] if typeOf(b) != 'block'
    when 'array' then switch typeOf b
      when 'array' then return [a, b]
      when 'int' then return [a, [b]]
    when 'int' then return [a, b] if typeOf(b) == 'int'

  coerce(b, a).reverse()

module.exports.makeBlock = makeBlock = (code) ->
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
