###*
 * source: jsonp.coffee
###

###
 *  ISC License (ISC)
 *  Copyright (c) 2016, Al Carruth <al.carruth@gmail.com>
 * 
 *  Permission to use, copy, modify, and/or distribute this software for
 *  any purpose with or without fee is hereby granted, provided that the
 *  above copyright notice and this permission notice appear in all
 *  copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
 *  WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
 *  WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
 *  AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
 *  CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
 *  OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
 *  NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
 *  CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
###

___dummy___ = 'ignore this !-)'

### Class JSONP_Controller ###
###*
 * A JSONP_Controller instance can be used to make a jsonp request to an api server.
 * @constructor
 * @param {string} base_url - the base_url for the server
 * @param {string} cb_prefix - used in naming the jsonp callback function
###
class JSONP_Controller

    ### constructor ###
    constructor: (@base_url, @cb_prefix) ->
        @cb_prefix = @cb_prefix || 'jsonp_callback_'
        ### seq_id is appended to the cb_prefix ###
        @seq_id = 0
        ### collect the requests for later inspection (maybe?) ###
        @requests = []
        
    ###*
     * method make_request()
     * returns a JSONP_Request object
     * @param {object} obj - query, success, error, msec
    ###
    make_request: (obj) =>

        ### the call back function name, unique to this call ###
        cb_name = @cb_prefix + @seq_id++
        
        ### add 'callback' to provided query object ###
        obj.query.callback = cb_name
        #obj.query['callback'] = cb_name

        ### construct the url from the base_url and the query object ###
        url = @base_url
        keys = Object.keys(obj.query)
        url += (key+'='+obj.query[key] for key in keys).join('&')
        url = encodeURI(url)

        request = new JSONP_Request(obj.success, obj.error, obj.msec, cb_name, url)
        @requests.push(request)
        return request

        
### Class JSONP_Request ###
###*
 * A JSONP_Request object is used to make a jsonp request to an api server.
 * @constructor
 * @param {function} success - executed upon successful jsonp response
 * @param {function} error - executed upon timeout
 * @param {int} msec - timeout delay in milliseconds
 * @param {string} cb_name 
 * @param {string} url - the url for jsonp call
###
class JSONP_Request

    ### constructor ###
    constructor: (@success, @error, @msec, @cb_name, @url) ->
        
        ### the parent node to be ###
        @head = document.getElementsByTagName('head')[0]
        
        ### the script element that enables this request ###
        @elt = document.createElement('script')
        @elt.type = 'text/javascript'
        @elt.async = true
        @elt.src = @url

        ### the below might be useful later, idk ###
        @elt.id = @cb_name
        @elt.className = 'jsonp-request'
        @elt.request = this

    ### method callback() ###
    callback: (data) =>
        window.clearTimeout(@timeout)
        @success(data)

    ### method send() ###
    send: =>
        window[@cb_name] = @callback
        @timeout = window.setTimeout(@error, @msec)
        ### appending @elt triggers the call to fetch the jsonp script ###
        @head.appendChild(@elt)


if window?
    window.JSONP_Controller = JSONP_Controller
