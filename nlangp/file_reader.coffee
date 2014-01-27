{EventEmitter} = require('events')
fs = require 'fs'
lineReader = require 'line-reader'

class FileReader

  words = {}
  mostCommonWord = 'asad'
  topCount = 0
  processCount = 0
  emitter = new EventEmitter

  constructor: (file)->
    emitter.on 'start', ->
      console.log 'Started'

    emitter.on 'finish', ->
      console.log 'Finished'
    read file

  countWords = (line)->
    console.log mostCommonWord
    line.map (elem)->
      count = ++words[elem] || 0
      if count > topCount
        topCount = count
        mostCommonWord = elem
      words[elem] = count

  processLine = (line, last) ->
    topCount = 0
    mostCommonWord = ''
    countWords line.split(' ')
    afterRead() if last

  afterRead = ->
    emitter.emit('finish')
    return false

  read = (file)->
    emitter.emit('start')
    lineReader.eachLine(file, processLine)

  words_in = ->
    words
  
  words: ->
    words_in()


exports.FileReader = FileReader