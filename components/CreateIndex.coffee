noflo = require 'noflo'

# @platform noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Add an index to an IndexedDB database'
  c.inPorts.add 'store',
    datatype: 'object'
  c.inPorts.add 'name',
    datatype: 'string'
  c.inPorts.add 'keypath',
    datatype: 'string'
  c.inPorts.add 'unique',
    datatype: 'boolean'
    control: true
    default: false
  c.inPorts.add 'multientry',
    datatype: 'boolean'
    control: true
    default: false
  c.outPorts.add 'index',
    datatype: 'object'
  c.outPorts.add 'store',
    datatype: 'object'
  c.outPorts.add 'error',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'store', 'name', 'keypath'
    unique = if input.hasData('unique') then input.getData('unique') else false
    multiEntry = if input.hasData('multientry') then input.getData('multientry') else false
    [store, name, keyPath] = input.getData 'store', 'name', 'keypath'
    store.onerror = (err) ->
      output.done err
    index = store.createIndex name, keyPath,
      unique: unique
      multiEntry: multiEntry
    store.onerror = null
    output.send
      index: index
    output.sendDone
      store: store
