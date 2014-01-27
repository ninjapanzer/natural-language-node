sys = require('sys')
redis = require("redis")
{EventEmitter} = require('events')
{spawn} = require('child_process')

{FileReader} = require('./file_reader.coffee')
{DictionaryLoader} = require('./twitter_reader.coffee')

#f = new FileReader('sentences.txt')
emitter = new EventEmitter

#console.log "hi"

puts = (error, stdout, stderr)->
  sys.puts(stdout)

redisProcess = spawn('redis-server', ['redis.conf']);

spawnDataWatcher= (data)->
  string = data.toString()
  console.log('stdout: ' + data);
  if /The server is now ready to accept connections on port/.test string
    emitter.emit("redis_up")
  if /Address already in use/.test string
    emitter.emit("redis_running")

redisProcess.stdout.on 'data', spawnDataWatcher

startProcessing = ->
  loader = new DictionaryLoader()

redis_up_callback = ->
  console.log "redis up"
  emitter.removeListener('redis_up', redis_up_callback)
  redisProcess.stdout.removeListener 'data', spawnDataWatcher
  startProcessing()

emitter.on 'redis_up', redis_up_callback

emitter.on 'redis_running', redis_up_callback

process.on 'exit',
  ->
    redisProcess.kill(0)

    #lineReader.eachLine('sentences.txt', Reader.processFile)
    #ineReader.eachLine('chat_log.txt', Reader.processFile)