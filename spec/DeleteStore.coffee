noflo = require 'noflo'
iDB = window.overrideIndexedDB or window.indexedDB or window.mozIndexedDB or window.webkitIndexedDB or window.msIndexedDB
unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-indexeddb'

describe 'DeleteStore component', ->
  c = null
  name = null
  db = null
  err = null
  outDb = null
  dbName = 'deletestore'
  dbName = 'begintransaction'
  loader = null
  before ->
    loader = new noflo.ComponentLoader baseDir
  beforeEach (done) ->
    @timeout 4000
    loader.load 'indexeddb/DeleteStore', (e, instance) ->
      return done e if e
      c = instance
      name = noflo.internalSocket.createSocket()
      db = noflo.internalSocket.createSocket()
      outDb = noflo.internalSocket.createSocket()
      err = noflo.internalSocket.createSocket()
      c.inPorts.name.attach name
      c.inPorts.db.attach db
      c.outPorts.db.attach outDb
      c.outPorts.error.attach err
      done()
  after (done) ->
    req = iDB.deleteDatabase dbName
    req.onsuccess = -> done()

  describe 'on upgrade request', ->
    it 'should be able to delete an object store', (done) ->
      dbInstance = null

      err.once 'data', (data) ->
        dbInstance.close()
        done data
      outDb.on 'data', (data) ->
        chai.expect(typeof data).to.equal 'object'
        chai.expect(data.objectStoreNames.contains('items')).to.equal false
      name.send 'items'
      req = iDB.open dbName, 1
      req.onupgradeneeded = (e) ->
        e.target.result.createObjectStore 'items'
      req.onsuccess = (e) ->
        e.target.result.close()
        req2 = iDB.open dbName, 2
        req2.onupgradeneeded = (e) ->
          dbInstance = e.target.result
          db.send dbInstance
        req2.onsuccess = (e) ->
          dbInstance.close()
          done()
