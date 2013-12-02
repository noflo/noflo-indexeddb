noflo = require 'noflo'

class QueryOnly extends noflo.Component
  constructor: ->
    @inPorts =
      value: new noflo.Port 'all'
    @outPorts =
      range: new noflo.Port 'object'

    @inPorts.value.on 'data', (value) =>
      @outPorts.out.send IDBKeyRange.only value
      @outPorts.out.disconnect()

exports.getComponent = -> new QueryOnly
