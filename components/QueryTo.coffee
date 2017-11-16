noflo = require 'noflo'

# @platform noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'search'
  c.description = 'Query up to a key in store in an IndexedDB database'
  c.inPorts.add 'value',
    datatype: 'all'
  c.inPorts.add 'including',
    datatype: 'boolean'
    control: true
    default: false
  c.outPorts.add 'range',
    datatype: 'object'
  c.forwardBrackets =
    value: ['range']
  c.process (input, output) ->
    return unless input.hasData 'value'
    value = input.getData 'value'
    including = if input.hasData('including') then input.getData('including') else false
    range = IDBKeyRange.upperBound value, including
    output.sendDone
      range: range
