noflo = require 'noflo'

# @platform noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Start an IndexedDB transaction'
  c.inPorts.add 'stores',
    datatype: 'string'
  c.inPorts.add 'db',
    datatype: 'object'
  c.inPorts.add 'mode',
    datatype: 'string'
    default: 'readwrite'
    control: true
  c.outPorts.add 'transaction',
    datatype: 'object'
  c.outPorts.add 'db',
    datatype: 'object'
  c.outPorts.add 'error',
    datatype: 'object'
  c.outPorts.add 'complete',
    datatype: 'bang'
  c.process (input, output) ->
    return unless input.hasData 'db', 'stores'
    mode = if input.hasData('mode') then input.getData('mode') else 'readwrite'
    [db, stores] = input.getData 'db', 'stores'
    if typeof stores is 'string'
      stores = stores.split ','
    try
      transaction = db.transaction stores, mode
    catch e
      return output.done e
    transaction.oncomplete = ->
      output.send
        complete: true
      transaction.onerror = null
      transaction.oncomplete = null
      output.done()
    transaction.onerror = (err) ->
      output.done err
    output.send
      transaction: transaction
    output.send
      db: db
