/**
 * source: neighborhood_map.coffee
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
    var Info_View, Map_View, Marker_View, Menu_View, Neighborhood_Map, Place, neighborhood_Map,
        bind = function(fn, me) {
            return function() {
                return fn.apply(me, arguments);
            };
        };

    /* Class Menu_View */
    /**
     * A Menu_View is a view of the neighborhood places as a list of clickable items
     * @constructor
     * @param {Neighborhood_Map} app - the main neighborhood map instance
     */
    Menu_View = (function() {

        /* constructor */
        function Menu_View(app) {
            this.app = app;
            this.toggle = bind(this.toggle, this);
            this.menu_Element = document.getElementById('menu-view');
            this.menu_Button = document.getElementById('menu-button');
            this.hidden = ko.observable(false);
        }


        /**
         * method toggle()
         * toggles the visibility of the menu
         */
        Menu_View.prototype.toggle = function() {
            return this.hidden(!this.hidden());
        };

        return Menu_View;

    })();


    /* Class Map_View */
    /**
     * A Map_View is a view of the neighbohood places on a map.
     * @constructor
     * @param {Neighborhood_Map} app - the main neighborhood map instance
     */
    Map_View = (function() {

        /* constructor */
        function Map_View(app) {
            this.app = app;
            this.error = bind(this.error, this);
            this.init = bind(this.init, this);
            this.map_Element = document.getElementById('map-view');
            this.gm_request = this.app.google_Maps.get({
                query: {
                    libraries: 'places'
                },
                success: this.init,
                error: this.error,
                msec: 3000
            });
        }

        Map_View.prototype.init = function() {
            this.map = new google.maps.Map(this.map_Element, {
                center: {
                    lat: 30.2712406,
                    lng: -97.7555901
                },
                scrollwheel: true,
                zoom: 13,
                disableDefaultUI: true,
                callback: this.error
            });
            return this.app.map_Ready();
        };

        Map_View.prototype.error = function(err) {
            return window.alert("Google Maps is currently unavailable");
        };

        return Map_View;

    })();


    /* Class Marker_View */
    /**
     * A Marker_View is a view of a place as a map marker on the map.
     * @constructor
     * @param {PLace} place - an instance of the Place class 
     * @param {Map_View} map_View - an instance of the Map_View class
     */
    Marker_View = (function() {
        var marker_Highlight_Icon, marker_Icon;

        marker_Icon = "https://maps.google.com/mapfiles/ms/icons/green-dot.png";

        marker_Highlight_Icon = "https://maps.google.com/mapfiles/ms/icons/blue-dot.png";


        /* constructor */
        function Marker_View(place1, map_View) {
            this.place = place1;
            this.map_View = map_View;
            this.highlight = bind(this.highlight, this);
            this.display = bind(this.display, this);
            this.marker = new google.maps.Marker({
                position: this.place.loc,
                optimized: false,
                zIndex: 1000,
                map: this.map_View.map,
                title: this.place.name(),
                icon: marker_Icon,
                opacity: 1.0
            });
            this.marker.addListener('click', this.place.click);
            this.place.visible.subscribe(this.display);
            this.place.selected.subscribe(this.highlight);
        }


        /* method display() */
        Marker_View.prototype.display = function(show_marker) {
            return this.marker.setVisible(show_marker);
        };


        /* method highlight() */
        Marker_View.prototype.highlight = function(hl_true) {
            if (hl_true) {
                this.marker.setIcon(marker_Highlight_Icon);
                return this.marker.setZIndex(1001);
            } else {
                this.marker.setIcon(marker_Icon);
                return this.marker.setZIndex(1000);
            }
        };

        return Marker_View;

    })();


    /* Class Info_View */
    /**
     * An Info_View is a view of a Place as a popup InfoWindow
     * @constructor
     * @param {Place} place
     * @param {Map_View} map_View
     * @param {Marker_View} marker_View
     */
    Info_View = (function() {

        /* constructor */
        function Info_View(place1, map_View, marker_View) {
            var s;
            this.place = place1;
            this.map_View = map_View;
            this.marker_View = marker_View;
            this.display = bind(this.display, this);
            this.display_Wikipedia_Info = bind(this.display_Wikipedia_Info, this);
            this.display_Info = bind(this.display_Info, this);
            this.wikipedia_Info = void 0;
            s = '<span class="error-msg"> Wikipedia is currently unavailable. </span> <br>';
            this.error_Msg = s + '<span class="error-msg"> Please try again later. </span>';
            this.info_Window = new google.maps.InfoWindow({
                maxWidth: 250
            });
            this.info_Window.addListener('closeclick', this.place.click);
            this.place.show_info.subscribe(this.display);
        }


        /**
         * method display_Info()
         * helper function for method display_Wikipedia_Info()
         * @param {Object} obj - contains title, description and url
         */
        Info_View.prototype.display_Info = function(obj) {
            var s;
            s = '<div class="info-window">' + 
                    '<h1 class="info-window-h1">' + obj.title + '</h1>' + 
                    '<p class="info-window-p">' + obj.description + '</p>' +
                    '<a href="' + obj.url + '" target="_blank"> Wikipedia </a>' +
                    '</div>';
            this.info_Window.setContent(s);
            return this.info_Window.open(this.map_View.map, this.marker_View.marker);
        };


        /**
         * method display_Wikipedia_Info()
         * display either the info from wikipedia or an error message
         * @param {Boolean} show_marker - to display or not display
         */
        Info_View.prototype.display_Wikipedia_Info = function() {
            if (typeof this.wikipedia_Info !== 'undefined') {
                return this.display_Info(this.wikipedia_Info);
            } else {
                return this.place.app.wikipedia.openSearch({
                    search_Str: this.place.wikipedia_Title,
                    success: ((function(_this) {
                        return function(data) {
                            _this.wikipedia_Info = {
                                title: data[1][0],
                                description: data[2][0],
                                url: data[3][0]
                            };
                            return _this.display_Info(_this.wikipedia_Info);
                        };
                    })(this)),
                    error: ((function(_this) {
                        return function() {
                            return _this.display_Info({
                                title: _this.place.name(),
                                description: _this.error_Msg,
                                url: "https://en.wikipedia.org/"
                            });
                        };
                    })(this))
                });
            }
        };


        /**
         * method display()
         * @param {Boolean} show_window - to display or not display
         */
        Info_View.prototype.display = function(show_Window) {
            if (show_Window) {
                return this.display_Wikipedia_Info();
            } else {
                return this.info_Window.close();
            }
        };

        return Info_View;

    })();


    /* Class Place */
    /**
     * A Place is part of the view model.  It is constructed from a simple object
     * and is associated with a Marker_View, an Info_View and a
     * div.menu-list-item element as part of the Menu_View.
     * @constructor
     * @param {object} obj - a simple object containing the name, location and wikipedia title
     * @param {Neighborhood_Map} @app - the main app instance
     */
    Place = (function() {

        /* constructor */
        function Place(obj, app) {
            this.app = app;
            this.display = bind(this.display, this);
            this.click = bind(this.click, this);
            this.map_Ready = bind(this.map_Ready, this);
            this.loc = obj.loc;
            this.name = ko.observable(obj.name);
            this.wikipedia_Title = obj.wikipedia_title;
            this.state = ko.observable(1);
            this.hidden = ko.computed((function(_this) {
                return function() {
                    return _this.state() === 0;
                };
            })(this));
            this.visible = ko.computed((function(_this) {
                return function() {
                    return _this.state() > 0;
                };
            })(this));
            this.selected = ko.computed((function(_this) {
                return function() {
                    return _this.state() > 1;
                };
            })(this));
            this.show_info = ko.computed((function(_this) {
                return function() {
                    return _this.state() > 1;
                };
            })(this));
        }

        Place.prototype.map_Ready = function() {
            this.marker_View = new Marker_View(this, this.app.map_View);
            return this.info_View = new Info_View(this, this.app.map_View, this.marker_View);
        };


        /**
         * method click() handles all clicks whether on the menu items or
         * on the map markers and cycles through the states appropriately
         */
        Place.prototype.click = function() {

            /* de-select all other places */
            var i, len, place, ref;
            ref = this.app.places();
            for (i = 0, len = ref.length; i < len; i++) {
                place = ref[i];
                if (place !== this && place.state() > 1) {
                    place.state(1);
                }
            }

            /* change to next state */
            this.state([1, 2, 1][this.state()]);

            /* hide the menu after selection when in cell phone mode. */
            if (window.innerWidth < 700) {
                return this.app.menu_View.hidden(true);
            }
        };


        /**
         * method display
         * @param {Boolean} boolean_expr - to display or not display
         */
        Place.prototype.display = function(bool_expr) {
            if (bool_expr) {
                return this.state(Math.max(1, this.state()));
            } else {
                return this.state(0);
            }
        };

        return Place;

    })();


    /* Class Neighborhood_Map */
    /**
     * An instance of class Neighborhood_Map is the main app.
     * @constructor
     */
    Neighborhood_Map = (function() {

        /* constructor */
        function Neighborhood_Map() {
            this.search = bind(this.search, this);
            this.init = bind(this.init, this);
            this.map_Ready = bind(this.map_Ready, this);
            this.wikipedia = new Wikipedia('Map of Austin places');
            this.google_Maps = new Google_Maps("AIzaSyBjtVDpeVL8JzhYqCXt8d6E3bRanaNCXEo");
            this.places = ko.observableArray([]);
            this.menu_View = new Menu_View(this);
            this.map_View = new Map_View(this);
            this.app_Element = document.getElementById('neighborhood-map');
            this.search_Str = ko.observable('');
            this.search_Str.subscribe(this.search);
            ko.applyBindings(this, this.app_Element);
        }


        /**
         * method map_Ready
         */
        Neighborhood_Map.prototype.map_Ready = function() {
            var i, len, place, ref, results;
            ref = this.places();
            results = [];
            for (i = 0, len = ref.length; i < len; i++) {
                place = ref[i];
                results.push(place.map_Ready());
            }
            return results;
        };


        /**
         * method init
         * @param {JSON} places_JSON - a json string representing an array of simple place objects
         */
        Neighborhood_Map.prototype.init = function(places_JSON) {
            var i, len, obj, ref, results;
            this.places_JSON = places_JSON;
            this.places([]);
            ref = JSON.parse(this.places_JSON);
            results = [];
            for (i = 0, len = ref.length; i < len; i++) {
                obj = ref[i];
                results.push(this.places.push(new Place(obj, this)));
            }
            return results;
        };


        /**
         * method search
         * @param {String} pat - the patern to search for
         */
        Neighborhood_Map.prototype.search = function(pat) {
            var expr, i, len, place, ref, results;
            expr = RegExp(pat, 'i');
            ref = this.places();
            results = [];
            for (i = 0, len = ref.length; i < len; i++) {
                place = ref[i];
                results.push(place.display(expr.test(place.name())));
            }
            return results;
        };

        return Neighborhood_Map;

    })();

    if (typeof window !== "undefined" && window !== null) {
        neighborhood_Map = new Neighborhood_Map();
        neighborhood_Map.init(austin_Places_JSON);
        window.neighborhood_Map = neighborhood_Map;
    }

}).call(this);
