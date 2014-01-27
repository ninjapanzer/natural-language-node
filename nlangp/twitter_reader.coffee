util = require('util')
redis = require('redis')
twitter = require('twitter');



class DictionaryLoader

  redisConnection = undefined

  constructor: ->
    redisConnection = redis.createClient('6381');
    process.on 'exit', ->
      redisConnection.quit();
      console.log "quitting redis"
    streamTwitter()
    

  streamTwitter= ->
    twit = new twitter({
      consumer_key: 'Lyw3Jlh3NMlTh1qxgV2EHw',
      consumer_secret: 'tCGZYViupuKDmZG2u3FvP9sZ3UCSLeDD5nBBnjdVUQ',
      access_token_key: '10940832-ArsonQwANGqd3dmucMPQTOQEWc1VBcgjVzW3MWPfq',
      access_token_secret: '7I8gJaHCwdWzfUHZCTHOaGpDitR904oZOWc20VWFrzPJ0'
    });

    twit.stream "statuses/sample", (stream) ->
      stream.on "data", (data) ->
        processLine data.text unless data.text == undefined

  processLine= (line) ->
    topCount = 0
    mostCommonWord = ''
    countWords line.split(' ')

  sortedSetPut= (word)->
    elem = word.toString('utf8').toLowerCase()
    redisConnection.zscore 'sorted_dictionary', elem, (err, reply)->
      console.log("Sorted #{elem} : #{reply}")
      if reply == null
        redisConnection.zadd("sorted_dictionary", 1, elem, ->);
      else
        val = parseInt(reply)
        redisConnection.zincrby("sorted_dictionary", 1, elem, ->);

  caseSensitivePut= (word) ->
    elem = word.toString('utf8')
    redisConnection.hget 'sensitive_dictionary', elem, (err, reply)->
      console.log("Sensitive #{elem} : #{reply}")
      if reply == null
        redisConnection.hset("sensitive_dictionary", elem, 1, ->);
      else
        val = parseInt(reply)
        redisConnection.hset("sensitive_dictionary", elem, ++val, ->);

  caseInsensitivePut= (word) ->
    elem = word.toString('utf8').toLowerCase()
    redisConnection.hget 'insensitive_dictionary', elem, (err, reply)->
      console.log("Insensitive #{elem} : #{reply}")
      if reply == null
        redisConnection.hset("insensitive_dictionary", elem, 1, ->);
      else
        val = parseInt(reply)
        redisConnection.hset("insensitive_dictionary", elem, ++val, ->);

  countWords = (line)->
    line.map (elem)->
      caseSensitivePut elem
      caseInsensitivePut elem
      sortedSetPut elem



exports.DictionaryLoader = DictionaryLoader