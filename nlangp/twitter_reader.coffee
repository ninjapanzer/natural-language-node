util = require('util')
redis = require('redis')
twitter = require('twitter');



class DictionaryLoader

  redisConnection = undefined

  constructor: ->
    redisConnection = redis.createClient('6381');
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
        console.log util.inspect(data.text)
        processLine data.text unless data.text == undefined

  processLine= (line) ->
    topCount = 0
    mostCommonWord = ''
    countWords line.split(' ')

  countWords = (line)->
    line.map (elem)->
      redisConnection.hget 'dictionary', elem, (err, reply)->
        if reply == null
          redisConnection.hset("dictionary", elem, 0, redis.print);
        else
          val = parseInt(reply)
          redisConnection.hset("dictionary", elem, ++val, redis.print);
    redisConnection.hgetall('dictionary', -> redis.print)


exports.DictionaryLoader = DictionaryLoader