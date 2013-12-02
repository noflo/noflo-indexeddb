noflo = require 'noflo'

class Open extends noflo.Component
  constructor: ->
    @name = null
    @version = null
    @inPorts =
      name: new noflo.Port 'name'
      version: new noflo.Port 'number'
    @outPorts =
      upgrade: new noflo.Port 'object'
      db: new noflo.Port 'object'
      error: new noflo.Port 'object'

    @inPorts.name.on 'data', (@name) =>
      do @open
    @inPorts.version.on 'data', (@version) =>
      do @open

  open: ->
    return unless @name and @version
    req = indexedDB.open @name, @version
    req.onupgradeneeded = (e) =>
      @outPorts.upgrade.send e.target.result
      @outPorts.upgrade.disconnect()
    req.onsuccess = (e) =>
      @outPorts.db.send e.target.result
      @outPorts.db.disconnect()
    req.onerror = @error

exports.getComponent = -> new Open
