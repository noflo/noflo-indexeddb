noflo = require 'noflo'

# @platform noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'search'
  c.description = 'Query only a key in store in an IndexedDB database'
  c.inPorts.add 'value',
    datatype: 'all'
  c.outPorts.add 'range',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'value'
    value = input.getData 'value'
    range = IDBKeyRange.only value
    output.sendDone
      range: range
