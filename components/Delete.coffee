noflo = require 'noflo'

# @platform noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Remove an item from an IndexedDB database'
  c.icon = 'trash'
  c.inPorts.add 'store',
    datatype: 'object'
  c.inPorts.add 'key',
    datatype: 'string'
  c.outPorts.add 'store',
    datatype: 'object'
  c.outPorts.add 'key',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'store', 'key'
    [store, key] = input.getData 'store', 'key'
    req = store.delete key
    req.onerror = (err) ->
      output.done err
    req.onsuccess = (e) ->
      output.send
        store: store
      output.send
        key: key
      output.done()
