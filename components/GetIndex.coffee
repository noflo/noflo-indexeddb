noflo = require 'noflo'

# @platform noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'store',
    datatype: 'object'
  c.inPorts.add 'name',
    datatype: 'string'
  c.outPorts.add 'index',
    datatype: 'object'
  c.outPorts.add 'error',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'store', 'name'
    [store, name] = input.getData 'store', 'name'
    store.onerror = (err) ->
      output.done err
    index = store.index name
    store.onerror = null
    output.sendDone
      index: index
