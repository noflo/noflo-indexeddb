noflo = require 'noflo'

# @platform noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'value',
    datatype: 'all'
  c.inPorts.add 'including',
    datatype: 'boolean'
    control: true
    default: false
  c.outPorts.add 'range',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'value'
    value = input.getData 'value'
    including = if input.hasData('including') then input.getData('including') else false
    range = IDBKeyRange.lowerBound value, including
    output.sendDone
      range: range
