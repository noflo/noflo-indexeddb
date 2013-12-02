noflo = require 'noflo'

class UpgradeRouter extends noflo.Component
  constructor: ->
    @groups = []
    @inPorts =
      upgrade: new noflo.Port 'object'
    @outPorts =
      versions: new noflo.ArrayPort 'object'
      missed: new noflo.Port 'object'

    @inPorts.upgrade.on 'begingroup', (group) =>
      @groups.push group
    @inPorts.upgrade.on 'data', (upgrade) =>
      @route upgrade
    @inPorts.upgrade.on 'endgroup', =>
      @groups.pop()
    @inPorts.upgrade.on 'disconnect', =>
      @groups = []

  route: (upgrade) ->
    if @outPorts.versions.isAttached upgrade.oldVersion
      @outPorts.versions.beginGroup group for group in @groups
      @outPorts.versions.send upgrade.db
      @outPorts.versions.endGroup() for group in @groups
      @outPorts.versions.disconnect()
      return
    return unless @outPorts.missed.isAttached()
    @outPorts.missed.beginGroup group for group in @groups
    @outPorts.missed.send upgrade.db
    @outPorts.missed.endGroup() for group in @groups
    @outPorts.missed.disconnect()

exports.getComponent = -> new UpgradeRouter
