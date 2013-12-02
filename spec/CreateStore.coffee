noflo = require 'noflo'
CreateStore = require 'noflo-indexeddb/components/CreateStore.js'

describe 'CreateStore component', ->
  c = null
  name = null
  db = null
  store = null
  dbName = 'createstore'
  beforeEach ->
    c = CreateStore.getComponent()
    name = noflo.internalSocket.createSocket()
    db = noflo.internalSocket.createSocket()
    store = noflo.internalSocket.createSocket()
    c.inPorts.name.attach name
    c.inPorts.db.attach db
    c.outPorts.store.attach store
  after ->
    indexedDB.deleteDatabase dbName

  describe 'on upgrade request', ->
    it 'should be able to create an object store', (done) ->
      store.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        done()
      name.send 'items'
      req = indexedDB.open dbName, 1
      req.onupgradeneeded = (e) ->
        db.send e.target.result
