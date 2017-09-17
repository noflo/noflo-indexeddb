noflo = require 'noflo'

# @platform noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'name',
    datatype: 'string'
  c.inPorts.add 'db',
    datatype: 'object'
  c.outPorts.add 'db',
    datatype: 'object'
  c.outPorts.add 'error',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'name', 'db'
    [name, db] = input.getData 'name', 'db'
    db.transaction.onerror = (err) ->
      output.done err
    db.deleteObjectStore name
    db.transaction.onerror = null
    output.sendDone
      db: db
