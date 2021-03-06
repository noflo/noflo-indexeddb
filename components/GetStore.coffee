noflo = require 'noflo'

# @platform noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Get an object store from an IndexedDB database'
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
  c.forwardBrackets =
    name: ['store', 'error']
  c.process (input, output) ->
    return unless input.hasData 'name', 'transaction'
    [name, transaction] = input.getData 'name', 'transaction'
    transaction.onerror = (err) ->
      output.done err
    store = transaction.objectStore name
    transaction.onerror = null
    output.sendDone
      store: store
      transaction: transaction
