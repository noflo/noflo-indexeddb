noflo = require 'noflo'

# @platform noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'search'
  c.description = 'Query a store in an IndexedDB database'
  c.inPorts.add 'store',
    datatype: 'object'
  c.inPorts.add 'range',
    datatype: 'object'
  c.inPorts.add 'all',
    datatype: 'bang'
  c.outPorts.add 'item',
    datatype: 'all'
  c.outPorts.add 'range',
    datatype: 'object'
  c.outPorts.add 'error',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'store'
    step = (e) ->
      cursor = e.target.result
      return output.done() unless cursor
      output.send
        item: cursor.value
      cursor.continue()
    if input.hasData 'all'
      [store, all] = input.getData 'store', 'all'
      req = store.openCursor()
      req.onerror = (err) ->
        output.done err
      req.onsuccess = step
      return
    if input.hasData 'range'
      [store, range] = input.getData 'store', 'range'
      output.send
        range: range
      req = store.openCursor range
      req.onerror = (err) ->
        output.done err
      req.onsuccess = step
