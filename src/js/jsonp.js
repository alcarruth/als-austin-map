/**
 * source: jsonp.coffee
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
    var JSONP_Controller, JSONP_Request, ___dummy___,
        bind = function(fn, me) {
            return function() {
                return fn.apply(me, arguments);
            };
        };

    ___dummy___ = 'ignore this !-)';


    /* Class JSONP_Controller */
    /**
     * A JSONP_Controller instance can be used to make a jsonp request to an api server.
     * @constructor
     * @param {string} base_URL - the base url for the server
     * @param {string} cb_Prefix - used in naming the jsonp callback function
     */
    JSONP_Controller = (function() {

        /* constructor */
        function JSONP_Controller(base_URL, cb_Prefix) {
            this.base_URL = base_URL;
            this.cb_Prefix = cb_Prefix;
            this.make_Request = bind(this.make_Request, this);
            this.cb_Prefix = this.cb_Prefix || 'jsonp_Callback_';

            /* seq_ID is appended to the cb_Prefix */
            this.seq_ID = 0;

            /* collect the requests for later inspection (maybe?) */
            this.requests = [];
        }


        /**
         * method make_Request()
         * returns a JSONP_Request object
         * @param {object} obj - query, success, error, msec
         */
        JSONP_Controller.prototype.make_Request = function(obj) {

            /* the call back function name, unique to this call */
            var cb_Name, key, keys, request, url;
            cb_Name = this.cb_Prefix + this.seq_ID++;

            /* ADD 'CALLBACK' TO provided query object */
            obj.query.callback = cb_Name;

            /* construct the url from the base_URL and the query object */
            url = this.base_URL;
            keys = Object.keys(obj.query);
            url += ((function() {
                var i, len, results;
                results = [];
                for (i = 0, len = keys.length; i < len; i++) {
                    key = keys[i];
                    results.push(key + '=' + obj.query[key]);
                }
                return results;
            })()).join('&');
            url = encodeURI(url);
            request = new JSONP_Request(obj.success, obj.error, obj.msec, cb_Name, url);
            this.requests.push(request);
            return request;
        };

        return JSONP_Controller;

    })();


    /* Class JSONP_Request */
    /**
     * A JSONP_Request object is used to make a jsonp request to an api server.
     * @constructor
     * @param {function} success - executed upon successful jsonp response
     * @param {function} error - executed upon timeout
     * @param {int} msec - timeout delay in milliseconds
     * @param {string} cb_Name 
     * @param {string} url - the url for jsonp call
     */
    JSONP_Request = (function() {

        /* constructor */
        function JSONP_Request(success, error, msec, cb_Name1, url1) {
            this.success = success;
            this.error = error;
            this.msec = msec;
            this.cb_Name = cb_Name1;
            this.url = url1;
            this.send = bind(this.send, this);
            this.callback = bind(this.callback, this);

            /* the parent node to be */
            this.head = document.getElementsByTagName('head')[0];

            /* the script element that enables this request */
            this.elt = document.createElement('script');
            this.elt.type = 'text/javascript';
            this.elt.async = true;
            this.elt.src = this.url;

            /* the below might be useful later, idk */
            this.elt.id = this.cb_Name;
            this.elt.className = 'jsonp-request';
            this.elt.request = this;
        }


        /* method callback() */
        JSONP_Request.prototype.callback = function(data) {
            window.clearTimeout(this.timeout);
            return this.success(data);
        };


        /* method send() */
        JSONP_Request.prototype.send = function() {
            window[this.cb_Name] = this.callback;
            this.timeout = window.setTimeout(this.error, this.msec);

            /* appending @elt triggers the call to fetch the jsonp script */
            return this.head.appendChild(this.elt);
        };

        return JSONP_Request;

    })();

    if (typeof window !== "undefined" && window !== null) {
        window.JSONP_Controller = JSONP_Controller;
    }

}).call(this);