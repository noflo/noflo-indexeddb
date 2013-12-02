noflo = require 'noflo'

class Query extends noflo.Component
  constructor: ->
    @store = null
    @range = null
    @all = false

    @inPorts =
      store: new noflo.Port 'object'
      range: new noflo.Port 'object'
      all: new noflo.Port 'bang'
    @outPorts =
      item: new noflo.Port 'all'
      error: new noflo.Port 'object'

    @inPorts.store.on 'data', (@store) ->
      do @query
    @inPorts.range.on 'data', (@range) ->
      do @query
    @inPorts.all.on 'data', ->
      @all = true
      do @query

  query: ->
    return unless @store
    if @all
      req = @store.openCursor()
      @all = false
      req.onsuccess = @step
      req.onerror = @error
      return
    if @range
      req = @store.openCursor @range
      @range = null

  step: (e) =>
    cursor = e.target.result
    unless cursor
      @outPorts.item.disconnect()
      return
    @outPorts.item.beginGroup cursor.key
    @outPorts.item.send cursor.value
    @outPorts.item.endGroup()
    cursor.continue()

exports.getComponent = -> new Query
