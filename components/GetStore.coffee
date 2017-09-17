noflo = require 'noflo'

# @platform noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'name',
    datatype: 'string'
  c.inPorts.add 'transaction',
    datatype: 'object'
  c.outPorts.add 'store',
    datatype: 'object'
  c.outPorts.add 'transaction',
    datatype: 'object'
  c.outPorts.add 'error',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'name', 'transaction'
    [name, transaction] = input.getData 'name', 'transaction'
    transaction.onerror = (err) ->
      output.done err
    store = transaction.objectStore name
    transaction.onerror = null
    output.send
      store: store
    output.sendDone
      transaction: transaction
