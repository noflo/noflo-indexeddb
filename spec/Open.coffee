noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  Open = require '../components/Open.coffee'
else
  Open = require 'noflo-indexeddb/components/Open.js'

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
  after ->
    indexedDB.deleteDatabase 'indexeddb'

  describe 'on first openining', ->
    it 'should provide upgrade request', (done) ->
      upgrade.once 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        done()
      name.send 'indexeddb'
      version.send 1
  describe 'on second opening', ->
    it 'should provide the DB', (done) ->
      up = false
      upgrade.once 'data', (data) ->
        up = true
      db.once 'data', (data) ->
        chai.expect(up).to.equal false
        chai.expect(data).to.be.an 'object'
        done()
      name.send 'indexeddb'
      version.send 1
