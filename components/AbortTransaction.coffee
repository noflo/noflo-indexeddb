noflo = require 'noflo'

# @platform noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'transaction',
    datatype: 'object'
  c.outPorts.add 'transaction',
    datatype: 'object'
  c.outPorts.add 'error',
    datatype: 'object'
  c.forwardBrackets =
    transaction: ['transaction', 'error']
  c.process (input, output) ->
    return unless input.hasData 'transaction'
    transaction = input.getData 'transaction'
    transaction.onerror = (err) ->
      output.done err
    transaction.onabort = (err) ->
      output.sendDone
        transaction: transaction
    transaction.abort()
