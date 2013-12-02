noflo = require 'noflo'
DeleteStore = require 'noflo-indexeddb/components/DeleteStore.js'

describe 'DeleteStore component', ->
  c = null
  name = null
  db = null
  outDb = null
  dbName = 'deletestore'
  beforeEach ->
    c = DeleteStore.getComponent()
    name = noflo.internalSocket.createSocket()
    db = noflo.internalSocket.createSocket()
    outDb = noflo.internalSocket.createSocket()
    c.inPorts.name.attach name
    c.inPorts.db.attach db
    c.outPorts.db.attach outDb
  after ->
    indexedDB.deleteDatabase dbName

  describe 'on upgrade request', ->
    it 'should be able to delete an object store', (done) ->
      outDb.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.objectStoreNames.contains('items')).to.equal false
        done()
      name.send 'items'
      req = indexedDB.open dbName, 1
      req.onupgradeneeded = (e) ->
        e.target.result.createObjectStore 'items'
        db.send e.target.result
