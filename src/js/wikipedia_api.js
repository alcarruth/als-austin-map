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
    var Wikipedia, ___dummy___,
        bind = function(fn, me) {
            return function() {
                return fn.apply(me, arguments);
            };
        };

    ___dummy___ = 'ignore this !-)';


    /* Class Wikipedia */
    /**
     * A Wikipedia instance has methods for simple queries and searches
     * using the wikipedia api.
     * @constructor
     * @param {String} api_User_Agent - a string identifying the app to wikipedia
     */
    Wikipedia = (function() {

        /* constructor */
        function Wikipedia(api_User_Agent) {
            this.api_User_Agent = api_User_Agent;
            this.openSearch = bind(this.openSearch, this);
            this.query = bind(this.query, this);
            this.get = bind(this.get, this);
            this.handle_Timeout = bind(this.handle_Timeout, this);
            this.jsonp = new JSONP_Controller('https://en.wikipedia.org/w/api.php?');
        }


        /**
         * method handle_timeout()
         * a default timeout error handler for calls to method get() above
         * @param {Object} err - the error object
         */
        Wikipedia.prototype.handle_Timeout = function(err) {
            var msg;
            msg = "Wikipedia search results unavailable.";
            console.log(msg);
            return console.log(err);
        };


        /* method get() */
        Wikipedia.prototype.get = function(obj, query) {
            var request;
            request = this.jsonp.make_Request({
                query: query,
                success: obj.success,
                error: obj.error || this.handle_Timeout,
                msec: obj.msec || 3000
            });
            return request.send();
        };


        /**
         * method query()
         * performs the ajax request for a 'query' action
         * @param {Object} obj - a query string object
         */
        Wikipedia.prototype.query = function(obj) {
            return this.get(obj, {
                action: 'query',
                format: 'json',
                prop: 'revisions',
                rvprop: 'content',
                titles: obj.title
            });
        };


        /**
         * method openSearch()
         * performs the ajax request for an 'opensearch' action
         * @param {Object} obj - a query string object
         */
        Wikipedia.prototype.openSearch = function(obj) {
            return this.get(obj, {
                action: 'opensearch',
                format: 'json',
                search: obj.search_Str
            });
        };

        return Wikipedia;

    })();

    if (typeof window !== "undefined" && window !== null) {
        window.Wikipedia = Wikipedia;
    }

}).call(this);