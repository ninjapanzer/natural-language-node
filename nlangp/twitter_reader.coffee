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
    fs.readFile './twitter_config.json',{encodinf:String} , (err, data)->
      conf = JSON.parse(data)
      twit = new twitter({
        consumer_key: conf.consumer_key,
        consumer_secret: conf.consumer_secret,
        access_token_key: conf.access_token_key,
        access_token_secret: conf.access_token_secret
      })
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