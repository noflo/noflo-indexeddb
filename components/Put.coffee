noflo = require 'noflo'

# @platform noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Store an object into an IndexedDB store'
  c.inPorts.add 'store',
    datatype: 'object'
  c.inPorts.add 'value',
    datatype: 'all'
  c.outPorts.add 'store',
    datatype: 'object'
  c.outPorts.add 'key',
    datatype: 'string'
  c.outPorts.add 'value',
    datatype: 'all'
  c.outPorts.add 'error',
    datatype: 'object'
  c.forwardBrackets =
    value: ['key', 'value', 'error']
  c.process (input, output) ->
    return unless input.hasData 'store', 'value'
    [store, value] = input.getData 'store', 'value'
    req = store.put value
    output.send
      store: store
    req.onerror = (err) ->
      output.done err
    req.onsuccess = (e) ->
      output.sendDone
        key: e.target.result
        value: value
