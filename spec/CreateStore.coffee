noflo = require 'noflo'
CreateStore = require 'noflo-indexeddb/components/CreateStore.js'

describe 'CreateStore component', ->
  c = null
  name = null
  db = null
  store = null
  keypath = null
  dbName = 'createstore'
  beforeEach ->
    c = CreateStore.getComponent()
    name = noflo.internalSocket.createSocket()
    db = noflo.internalSocket.createSocket()
    store = noflo.internalSocket.createSocket()
    keypath = noflo.internalSocket.createSocket()
    c.inPorts.name.attach name
    c.inPorts.db.attach db
    c.inPorts.keypath.attach keypath
    c.outPorts.store.attach store
  after (done) ->
    req = indexedDB.deleteDatabase dbName
    req.onsuccess = -> done()

  describe 'on upgrade request', ->
    it 'should be able to create an object store', (done) ->
      dbInstance = null
      store.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
      store.on 'disconnect', ->
        dbInstance.close()
        done()
      keypath.send 'foo'
      name.send 'items'
      req = indexedDB.open dbName, 1
      req.onupgradeneeded = (e) ->
        dbInstance = e.target.result
        db.send dbInstance
