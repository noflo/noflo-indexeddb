noflo = require 'noflo'
Open = require 'noflo-indexeddb/components/Open.js'
iDB = require 'noflo-indexeddb/vendor/IndexedDB.js'

describe 'Open component', ->
  c = null
  name = null
  version = null
  upgrade = null
  db = null
  error = null
  beforeEach ->
    c = Open.getComponent()
    name = noflo.internalSocket.createSocket()
    version = noflo.internalSocket.createSocket()
    upgrade = noflo.internalSocket.createSocket()
    db = noflo.internalSocket.createSocket()
    error = noflo.internalSocket.createSocket()
    c.inPorts.name.attach name
    c.inPorts.version.attach version
    c.outPorts.upgrade.attach upgrade
    c.outPorts.db.attach db
    c.outPorts.error.attach error
  after (done) ->
    req = iDB.deleteDatabase 'opendb'
    req.onsuccess = -> done()

  describe 'on first openining', ->
    it 'should provide upgrade request', (done) ->
      upgrade.once 'data', (data) ->
        chai.expect(typeof data).to.equal 'object'
        chai.expect(data.oldVersion).to.equal 0
        chai.expect(typeof data.db).to.equal 'object'
        data.db.close()
        done()
      name.send 'opendb'
      version.send 1
  describe 'on second opening', ->
    it 'should provide the DB', (done) ->
      up = false
      upgrade.once 'data', (data) ->
        up = true
      db.once 'data', (data) ->
        chai.expect(up).to.equal false
        chai.expect(typeof data).to.equal 'object'
        data.close()
        done()
      name.send 'opendb'
      version.send 1
