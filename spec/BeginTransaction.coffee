noflo = require 'noflo'
iDB = window.overrideIndexedDB or window.indexedDB or window.mozIndexedDB or window.webkitIndexedDB or window.msIndexedDB
unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-indexeddb'

describe 'BeginTransaction component', ->
  c = null
  stores = null
  db = null
  transaction = null
  dbName = 'begintransaction'
  loader = null
  before ->
    loader = new noflo.ComponentLoader baseDir
  beforeEach (done) ->
    @timeout 4000
    loader.load 'indexeddb/BeginTransaction', (err, instance) ->
      return done err if err
      c = instance
      stores = noflo.internalSocket.createSocket()
      db = noflo.internalSocket.createSocket()
      transaction = noflo.internalSocket.createSocket()
      c.inPorts.stores.attach stores
      c.inPorts.db.attach db
      c.outPorts.transaction.attach transaction
      done()
  after (done) ->
    req = iDB.deleteDatabase dbName
    req.onsuccess = -> done()

  describe 'on upgrade request', ->
    it 'should be able to begin transaction', (done) ->
      dbInstance = null
      transaction.on 'data', (data) ->
        chai.expect(typeof data).to.equal 'object'
        dbInstance.close()
        done()
      stores.send 'items,users'
      req = iDB.open dbName, 1
      req.onupgradeneeded = (e) ->
        e.target.result.createObjectStore 'items'
        e.target.result.createObjectStore 'users'
      req.onsuccess = (e) ->
        dbInstance = e.target.result
        db.send dbInstance
