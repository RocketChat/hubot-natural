path = require 'path'
natural = require 'natural'

{applyVariable, msgVariables, stringElseRandomKey} = require path.join '..', 'lib', 'common.coffee'
answers = {}

class respond
  constructor: (@interaction) ->
  process: (msg) =>
    type = @interaction.type?.toLowerCase() or 'random'
    switch type
      when 'block'
        @interaction.message.forEach (line) ->
          message = msgVariables line, msg
          message = applyVariable message, 'clima', 'Chuvoso'
          message = applyVariable message, 'min', '3 °C'
          message = applyVariable message, 'max', '12 °C'
          msg['send'] message
      when 'random'
        message = stringElseRandomKey @interaction.message
        message = msgVariables message, msg
        msg['send'] message

module.exports = respond
