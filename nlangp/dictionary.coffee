mongo = require('mongodb');

class Dictionary

  word: ''
  totalCount: 0
  insensitiveCount: 0
  timestamp: new mongo.Timestamp()

  toJson: ->
    {
      word: @word
      totalCount: @totalCount
      insensitiveCount: @insensitiveCount
      timestamp: @timestamp
    }

exports.Dictionary = Dictionary