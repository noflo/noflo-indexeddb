noflo = require 'noflo'
iDB = window.overrideIndexedDB or window.indexedDB or window.mozIndexedDB or window.webkitIndexedDB or window.msIndexedDB
unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-indexeddb'

describe 'CreateStore component', ->
  c = null
  name = null
  db = null
  store = null
  keypath = null
  dbName = 'createstore'
  loader = null
  before ->
    loader = new noflo.ComponentLoader baseDir
  beforeEach (done) ->
    @timeout 4000
    loader.load 'indexeddb/CreateStore', (err, instance) ->
      return done err if err
      c = instance
      name = noflo.internalSocket.createSocket()
      db = noflo.internalSocket.createSocket()
      store = noflo.internalSocket.createSocket()
      keypath = noflo.internalSocket.createSocket()
      c.inPorts.name.attach name
      c.inPorts.db.attach db
      c.inPorts.keypath.attach keypath
      c.outPorts.store.attach store
      done()
  after (done) ->
    req = iDB.deleteDatabase dbName
    req.onsuccess = -> done()

  describe 'on upgrade request', ->
    it 'should be able to create an object store', (done) ->
      dbInstance = null
      store.on 'data', (data) ->
        chai.expect(typeof data).to.equal 'object'
      store.on 'disconnect', ->
        dbInstance.close()
        done()
      keypath.send 'foo'
      name.send 'items'
      req = iDB.open dbName, 1
      req.onupgradeneeded = (e) ->
        dbInstance = e.target.result
        db.send dbInstance
