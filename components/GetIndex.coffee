noflo = require 'noflo'

# @platform noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Get an index from an IndexedDB database'
  c.inPorts.add 'store',
    datatype: 'object'
  c.inPorts.add 'name',
    datatype: 'string'
  c.outPorts.add 'index',
    datatype: 'object'
  c.outPorts.add 'error',
    datatype: 'object'
  c.forwardBrackets =
    name: ['index', 'error']
  c.process (input, output) ->
    return unless input.hasData 'store', 'name'
    [store, name] = input.getData 'store', 'name'
    store.onerror = (err) ->
      output.done err
    index = store.index name
    store.onerror = null
    output.sendDone
      index: index
