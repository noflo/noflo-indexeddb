noflo = require 'noflo'

# @platform noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'store',
    datatype: 'object'
  c.inPorts.add 'key',
    datatype: 'string'
  c.outPorts.add 'store',
    datatype: 'object'
  c.outPorts.add 'item',
    datatype: 'all'
  c.outPorts.add 'error',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'store', 'key'
    [store, key] = input.getData 'store', 'key'
    req = store.get key
    output.send
      store: store
    req.onerror = (err) ->
      output.done err
    req.onsuccess = (e) ->
      output.sendDone
        item: e.target.result
