# TODO
#  rest of builtins
#  check with golfscript output
#  lb for arrays should decrement with pops
#  state kinda sucks (crappy references!)
#  do not console.log prints, put in buffer

coffee = require 'coffee-script'
lang = require './lang'
builtins = require './builtins'

module.exports[key] = val for key, val of lang

module.exports.run =
  (code, stack = [], variables = builtins()) ->
    lang.makeBlock(code) stack, variables

module.exports.BUILTINS = builtins()
