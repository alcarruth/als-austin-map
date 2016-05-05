/**
 * source: wikipedia_api.coffee
 */
/*
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
 */
(function() {
    var Google_Maps, ___dummy___,
        bind = function(fn, me) {
            return function() {
                return fn.apply(me, arguments);
            };
        };

    ___dummy___ = 'ignore this !-)';


    /* Class Google_Maps */
    /**
     * A Google_Maps instance has methods for simple queries and searches
     * using the google maps javascript api
     * @constructor
     * @param {String} api_User_Agent - a string identifying the app to wikipedia
     */
    Google_Maps = (function() {

        /* constructor */
        function Google_Maps(key) {
            this.key = key;
            this.get = bind(this.get, this);
            this.handle_Timeout = bind(this.handle_Timeout, this);
            this.jsonp = new JSONP_Controller('https://maps.googleapis.com/maps/api/js?');
        }


        /**
         * method handle_timeout()
         * a default timeout error handler for calls to method get() above
         * @param {Object} err - the error object
         */
        Google_Maps.prototype.handle_Timeout = function(err) {
            var msg;
            msg = "Google Maps unavailable.";
            console.log(msg);
            return console.log(err);
        };


        /* method get() */
        Google_Maps.prototype.get = function(obj, options) {
            var request;
            options = options || {};
            options.key = this.key;
            request = this.jsonp.make_Request({
                async: true,
                defer: true,
                query: options,
                success: obj.success,
                error: obj.error || this.handle_Timeout,
                msec: obj.msec || 3000
            });
            return request.send();
        };

        return Google_Maps;

    })();

    if (typeof window !== "undefined" && window !== null) {
        window.Google_Maps = Google_Maps;
    }

}).call(this);