{EventEmitter} = require 'events'

module.exports = ->

  # an optimization compatible way to make `arguments` into an array
  thrashers = []
  thrashers.push.apply thrashers, arguments

  # check if last one is an options object
  if typeof thrashers[thrashers.length - 1] is 'object'
    buildOptions = thrashers.pop

  # let's return a function which does the main work so we provide this:
  ###
  compare    = require '@thrash/compare'
  thrashOne  = thrash 'some-module1'
  thrashTwo  = thrash 'some-module2'
  thrashBoth = compare thrashOne, thrashTwo
  thrashBoth() <--- this
  ###
  runner = (runOptions) -> # no build options, compare only accepts thrashers
    runner.options = Object.assign {}, module.exports.defaults, buildOptions, runOptions
    runner.thrashing runner.options

  # check for a label
  if typeof thrashers[0] is 'string'
    runner.label = thrashers.shift()

  # set our executor on there as a property so it can be changed/wrapped/etc
  runner.thrashing = module.exports.thrashing

  # same with combiner
  runner.combineOptions = require './combine-options'

  # same with the thrashers array
  runner.thrashers = thrashers

  # also provide plugin ability: thrashIt.use '@thrash/console'
  runner.use = require '@use/core'

  # also make it (for the most part) like an event emitter
  runner.emitter = emitter = new EventEmitter
  runner.on   = emitter.on.bind emitter
  runner.once = emitter.once.bind emitter
  runner.off  = emitter.removeListener.bind emitter
  runner.emit = emitter.emit.bind emitter

  # forward all thrasher events to us to re-emit
  # NOTE: because the thrasher emit includes the thrasher as an arg we don't
  #       need to worry about adding that to differentiate one thrasher from another
  forwards = [ 'started', 'validated', 'optimized', 'thrashed', 'finished' ]
  for thrasher in thrashers
    thrasher.forward event, runner for event in forwards

  # TODO:
  #  the performance comparison stuff is currently in @thrash/console where
  #  it should *not* be.
  #  pull that into here as an event listener for performance info.
  #  then, emit the comparison results as a new event.
  #  then, @thrash/console can listen for that event to add that to its output.

  # all made. return it
  return runner


# store the defaults onto exports so they can be altered (shouldn't be needed)
module.exports.defaults =
  sequence: 'by-input' # instead of 'by-thrasher'

  # prevents inner thrashers from emitting a finished event
  emitStarted : false
  emitFinished: false


# exported so it can be messed with (replaced / wrapped)
module.exports.thrashing = (options) ->

  @emit 'started', this

  # iterate over all input generator functions
  for inputs in options.with

    # while the generator produces `input` call thrash
    while (input = inputs())?
      @emit 'input:start', this, input

      for thrash in @thrashers
        thrash input, options

      @emit 'input:end', this, input

  # all thrashers are finished
  thrasher.emit 'finished', thrasher for thrasher in @thrashers

  # and so are we
  @emit 'finished', this
