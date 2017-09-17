noflo = require 'noflo'
indexedDB = require '../vendor/IndexedDB'

# @platform noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'name',
    datatype: 'string'
  c.inPorts.add 'version',
    datatype: 'integer'
  c.outPorts.add 'upgrade',
    datatype: 'object'
  c.outPorts.add 'db',
    datatype: 'object'
  c.outPorts.add 'error',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'name', 'version'
    [name, version] = input.getData 'name', 'version'
    req = indexedDB.open name, parseInt version
    req.onerror = (err) ->
      output.done err
    req.onupgradeneeded = (e) ->
      output.send
        upgrade:
          oldVersion: e.oldVersion
          newVersion: parseInt version
          db: e.target.result
    req.onsuccess = (e) ->
      output.sendDone
        db: e.target.result
