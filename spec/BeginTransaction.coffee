noflo = require 'noflo'
BeginTransaction = require 'noflo-indexeddb/components/BeginTransaction.js'
iDB = require 'noflo-indexeddb/vendor/IndexedDB.js'

describe 'BeginTransaction component', ->
  c = null
  stores = null
  db = null
  transaction = null
  dbName = 'begintransaction'
  beforeEach ->
    c = BeginTransaction.getComponent()
    stores = noflo.internalSocket.createSocket()
    db = noflo.internalSocket.createSocket()
    transaction = noflo.internalSocket.createSocket()
    c.inPorts.stores.attach stores
    c.inPorts.db.attach db
    c.outPorts.transaction.attach transaction
  after (done) ->
    req = iDB.deleteDatabase dbName
    req.onsuccess = -> done()

  describe 'on upgrade request', ->
    it 'should be able to begin transaction', (done) ->
      dbInstance = null
      transaction.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
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
