events = require('events')

class Thing
  print = ->
    console.log 'print'
  printtoo: ->
    console.log 'otherprint'

Thing.prototype = new events.EventEmitter


thing = new Thing
thing.printtoo()
#thing.print()