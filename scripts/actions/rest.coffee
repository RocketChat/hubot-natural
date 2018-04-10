require 'coffeescript/register'

{ msgVariables, stringElseRandomKey } = require '../lib/common'

# interpolate a string to replace {{ placeholder }} keys with passed object values
# I couldn't find how to make delayed string interpolation with coffeescript yet :/
# Reference solution https://stackoverflow.com/questions/9829470/in-coffeescript-is-there-an-official-way-to-interpolate-a-string-at-run-time
String::interp = (values)->
    @replace /{{(.*)}}/g,
        (ph, key)->
            values[key] or ''
            
class Rest
  constructor: (@interaction) ->
  process: (msg) =>
    rest_uri = @interaction.rest_uri
    offline_message = (
      @interaction.offline or 'Sorry, there is no online agents to transfer to.'
    )
    type = @interaction.type?.toLowerCase() or 'random'
    switch type
      when 'block'
        messages = @interaction.answer.map (line) ->
          return msgVariables line, msg
        msg.sendWithNaturalDelay messages
      when 'random'
        message = stringElseRandomKey @interaction.answer
        message = msgVariables message, msg
        msg.sendWithNaturalDelay message

    method = @interaction.rest.method?.toLowerCase() or 'get'
    @rest(msg, 3000, rest_uri, offline_message, type, method)


  rest: (msg, delay = 3000, rest_uri, offline_message, type, method) ->
    data = JSON.stringify(@interaction.rest.data)
    successmsg = @interaction.rest.successmsg

    headers = @interaction.rest.headers
    
    headers = 
        'Content-Type': 'application/json'
    
    msg.http(@interaction.rest.url)
        .headers(headers)[method](data) (err, response, body) ->
            if response.statusCode isnt 200
                msg.sendWithNaturalDelay "We're sorry, something went wrong :/"
                return
            results = JSON.parse(body)
            message = successmsg.interp (results)
            msg.sendWithNaturalDelay message

module.exports = Rest
