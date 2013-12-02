noflo = require 'noflo'

class Put extends noflo.Component
  constructor: ->
    @store = null
    @value = null

    @inPorts =
      store: new noflo.Port 'object'
      value: new noflo.Port 'all'
    @outPorts =
      store: new noflo.Port 'object'
      item: new noflo.Port 'all'
      error: new noflo.Port 'object'

    @inPorts.store.on 'data', (@store) =>
      do @put
    @inPorts.value.on 'data', (@value) =>
      do @put

  put: ->
    return unless @store and @value
    req = @store.put @value
    @value = null
    req.onsuccess = (e) =>
      if @outPorts.item.isAttached()
        @outPorts.item.send e.target.result
        @outPorts.item.disconnect()
      if @outPorts.store.isAttached()
        @outPorts.store.send @store
        @outPorts.store.disconnect()
      @store = null
    req.onerror = @error

exports.getComponent = -> new Put
