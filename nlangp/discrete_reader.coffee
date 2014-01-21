fs = require 'fs'
lineReader = require 'line-reader'
redis = require("redis"),
client = redis.createClient();

words = {}
mostCommonWord = ''
topCount = 0

printWords = ->
  console.log words

countWords = (line)->
  line.map (elem)->
    count = ++words[elem] || 0
    if count > topCount
      topCount = count
      mostCommonWord = elem
    words[elem] = count

printMostCommonWord = ->
  console.log mostCommonWord
  console.log topCount

afterRead = ->
  #printWords()
  printMostCommonWord()

processFile = (line, last) ->
  topCount = 0
  mostCommonWord = ''
  countWords line.split(' ')
  afterRead() if last

lineReader.eachLine('sentences.txt', processFile)
lineReader.eachLine('chat_log.txt', processFile)