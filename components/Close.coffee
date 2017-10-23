noflo = require 'noflo'

# @platform noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Close an IndexedDB database'
  c.inPorts.add 'db',
    datatype: 'object'
  c.outPorts.add 'closed',
    datatype: 'bang'
  c.process (input, output) ->
    return unless input.hasData 'db'
    db = input.getData 'db'
    db.onclose = ->
      output.sendDone
        closed: true
    db.close()
