noflo = require 'noflo'

class QueryFrom extends noflo.Component
  constructor: ->
    @including = false
    @inPorts =
      value: new noflo.Port 'all'
      including: new noflo.Port 'boolean'
    @outPorts =
      range: new noflo.Port 'object'

    @inPorts.value.on 'data', (value) =>
      @outPorts.out.send IDBKeyRange.lowerBound value, @including
      @outPorts.out.disconnect()
    @inPorts.including.on 'data', (@including) =>

exports.getComponent = -> new QueryFrom
