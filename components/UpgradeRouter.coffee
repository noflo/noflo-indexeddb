noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'code-fork'
  c.description = 'Route upgrades between IndexeDB database versions'
  c.inPorts.add 'upgrade',
    datatype: 'object'
  c.outPorts.add 'versions',
    datatype: 'object'
    addressable: true
  c.outPorts.add 'missed',
    datatype: 'object'
  c.forwardBrackets =
    upgrade: ['versions', 'missed']
  c.process (input, output) ->
    return unless input.hasData 'upgrade'
    upgrade = input.getData 'upgrade'
    missed = false
    migration = 0
    while migration < upgrade.newVersion
      if migration < upgrade.oldVersion
        migration++
        continue
      unless c.outPorts.versions.isAttached migration
        migration++
        missed = true
        continue
      output.send
        versions: new noflo.IP 'data', upgrade.db,
          index: migration
      migration++
    return output.done() unless missed
    output.sendDone
      missed: upgrade.db
