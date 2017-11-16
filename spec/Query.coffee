noflo = require 'noflo'
iDB = window.overrideIndexedDB or window.indexedDB or window.mozIndexedDB or window.webkitIndexedDB or window.msIndexedDB
unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-indexeddb'

describe 'Query component', ->
  c = null
  store = null
  all = null
  item = null
  empty = null
  error = null
  dbName = 'query'
  dbInstance = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'indexeddb/Query', (err, instance) ->
      return done err if err
      c = instance
      store = noflo.internalSocket.createSocket()
      all = noflo.internalSocket.createSocket()
      c.inPorts.store.attach store
      c.inPorts.all.attach all
      req = iDB.open dbName, 1
      req.onupgradeneeded = (e) ->
        e.target.result.createObjectStore 'items',
          keyPath: 'id'
      req.onsuccess = (e) ->
        dbInstance = e.target.result
        done()
      req.onerror = done
  after (done) ->
    dbInstance.close()
    req = iDB.deleteDatabase dbName
    req.onsuccess = -> done()
    req.onerror = done
  beforeEach ->
    item = noflo.internalSocket.createSocket()
    empty = noflo.internalSocket.createSocket()
    error = noflo.internalSocket.createSocket()
    c.outPorts.item.attach item
    c.outPorts.empty.attach empty
    c.outPorts.error.attach error
  afterEach ->
    c.outPorts.item.detach item
    c.outPorts.empty.detach empty
    c.outPorts.error.detach error

  describe 'with an empty database', ->
    it 'it should send to empty', (done) ->
      dbTransaction = dbInstance.transaction ['items']
      dbStore = dbTransaction.objectStore 'items'
      item.on 'data', ->
        done new Error 'Unexpected item received'
      empty.on 'data', ->
        done()
      error.on 'data', (err) ->
        done err
      store.send dbStore
      all.send true

  describe 'with a populated database', ->
    before (done) ->
      dbTransaction = dbInstance.transaction ['items'], 'readwrite'
      dbTransaction.oncomplete = ->
        done()
      dbTransaction.onerror = done
      dbStore = dbTransaction.objectStore 'items'
      req = dbStore.put
        id: 1
        hello: 'world'
      req.onerror = done
      req.onsuccess = ->
        req = dbStore.put
          id: 2
          foo: 'bar'
        req.onerror = done
    it 'it should send a stream of results', (done) ->
      dbTransaction = dbInstance.transaction ['items']
      dbStore = dbTransaction.objectStore 'items'

      expected = [
        '<'
        '{"id":1,"hello":"world"}'
        '{"id":2,"foo":"bar"}'
        '>'
      ]
      received = []
      item.on 'ip', (ip) ->
        if ip.type is 'openBracket'
          received.push '<'
        if ip.type is 'data'
          received.push JSON.stringify ip.data
        if ip.type is 'closeBracket'
          received.push '>'
        return unless received.length is expected.length
        chai.expect(received).to.eql expected
        done()
      empty.on 'data', ->
        done new Error 'Unexpected empty received'
      error.on 'data', (err) ->
        done err
      store.send dbStore
      all.send true
