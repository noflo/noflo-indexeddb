noflo = require 'noflo'
BeginTransaction = require 'noflo-indexeddb/components/BeginTransaction.js'

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
  after ->
    indexedDB.deleteDatabase dbName

  describe 'on upgrade request', ->
    it 'should be able to begin transaction', (done) ->
      transaction.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        done()
      stores.send 'items,users'
      req = indexedDB.open dbName, 1
      req.onupgradeneeded = (e) ->
        e.target.result.createObjectStore 'users'
        e.target.result.createObjectStore 'items'
      req.onsuccess = (e) ->
        db.send e.target.result

