noflo = require 'noflo'

# @platform noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Delete an object store from an IndexedDB database'
  c.icon = 'trash'
  c.inPorts.add 'name',
    datatype: 'string'
  c.inPorts.add 'db',
    datatype: 'object'
  c.outPorts.add 'deleted',
    datatype: 'string'
  c.outPorts.add 'db',
    datatype: 'object'
  c.outPorts.add 'error',
    datatype: 'object'
  c.forwardBrackets =
    name: ['deleted', 'error']
  c.process (input, output) ->
    return unless input.hasData 'name', 'db'
    [name, db] = input.getData 'name', 'db'
    db.transaction.onerror = (err) ->
      output.done err
    db.deleteObjectStore name
    db.transaction.onerror = null
    output.sendDone
      deleted: name
      db: db
