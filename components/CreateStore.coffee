noflo = require 'noflo'

# @platform noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Add an object store to an IndexedDB database'
  c.inPorts.add 'name',
    datatype: 'string'
  c.inPorts.add 'db',
    datatype: 'object'
  c.inPorts.add 'keypath',
    datatype: 'string'
    control: true
  c.inPorts.add 'autoincrement',
    datatype: 'boolean'
    control: true
    default: false
  c.outPorts.add 'store',
    datatype: 'object'
  c.outPorts.add 'db',
    datatype: 'object'
  c.outPorts.add 'error',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'name', 'db'
    keyPath = if input.hasData('keypath') then input.getData('keypath') else ''
    autoIncrement = if input.hasData('autoincrement') then input.getData('autoincrement') else false
    [name, db] = input.getData 'name', 'db'
    db.transaction.onerror = (err) ->
      output.done err
    store = db.createObjectStore name,
      keyPath: keyPath
      autoIncrement: autoIncrement
    db.transaction.onerror = null
    output.send
      store: store
    output.send
      db: db
    output.done()
