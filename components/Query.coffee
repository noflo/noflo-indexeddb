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
  c.outPorts.add 'empty',
    datatype: 'object'
  c.outPorts.add 'error',
    datatype: 'object'
  c.forwardBrackets =
    all: ['item', 'error']
    range: ['item', 'error']
  c.process (input, output) ->
    return unless input.hasData 'store'
    bracketed = false
    step = (e) ->
      cursor = e.target.result
      unless cursor
        if bracketed
          output.send
            item: new noflo.IP 'closeBracket'
        else
          output.send
            empty: true
        output.done()
        return
      unless bracketed
        output.send
          item: new noflo.IP 'openBracket'
        bracketed = true
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
