noflo = require 'noflo'
indexedDB = require '../vendor/IndexedDB'

# @platform noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Delete an IndexedDB database'
  c.icon = 'trash'
  c.inPorts.add 'name',
    datatype: 'string'
  c.outPorts.add 'deleted',
    datatype: 'bang'
  c.outPorts.add 'error',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'name'
    name = input.getData 'name'
    req = indexedDB.deleteDatabase name
    req.onerror = (err) ->
      output.done err
    req.onsuccess = ->
      output.sendDone
        deleted: true
