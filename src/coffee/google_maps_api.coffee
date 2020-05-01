#!/usr/bin/env coffee

### Class Google_Maps_API ###
###*
 * A Google_Maps instance has methods for simple queries and searches
 * using the google maps javascript api
 * @constructor
 * @param {String} api_User_Agent - a string identifying the app to wikipedia
###
class Google_Maps_API

  ### constructor ###
  constructor: (@key) ->
    @jsonp = new JSONP_Controller('https://maps.googleapis.com/maps/api/js?')

  ###*
   * method handle_timeout()
   * a default timeout error handler for calls to method get() above
   * @param {Object} err - the error object
  ###
  handle_Timeout: (err) =>
    msg = "Google Maps unavailable."
    console.log(msg)
    console.log(err)

  ### method get() ###
  get: (obj, options) =>
    options = options || {}
    options.key = @key
    request = @jsonp.make_Request({
      async: true
      defer: true
      query: options
      success: obj.success
      error: obj.error || @handle_Timeout
      msec: obj.msec || 3000
    })
    request.send()



