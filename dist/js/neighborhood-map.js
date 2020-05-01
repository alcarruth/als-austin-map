// Generated by CoffeeScript 2.4.1
(function() {
  //!/usr/bin/env coffee
  /* Class Marker_View */
  /**
   * A Marker_View is a view of a place as a map marker on the map.
   * @constructor
   * @param {PLace} place - an instance of the Place class 
   * @param {Map_View} map_View - an instance of the Map_View class 
   */
  var Google_Maps_API, Info_View, JSONP_Controller, JSONP_Request, Map_View, Marker_View, Menu_View, Neighborhood_Map, Place, Wikipedia_API;

  /* Class JSONP_Controller */
  /**
   * A JSONP_Controller instance can be used to make a jsonp request to an api server.
   * @constructor
   * @param {string} base_URL - the base url for the server
   * @param {string} cb_Prefix - used in naming the jsonp callback function
   */
  JSONP_Controller = class JSONP_Controller {
    /* constructor */
    constructor(base_URL, cb_Prefix) {
      /**
       * method make_Request()
       * returns a JSONP_Request object
       * @param {object} obj - query, success, error, msec
       */
      this.make_Request = this.make_Request.bind(this);
      this.base_URL = base_URL;
      this.cb_Prefix = cb_Prefix;
      this.cb_Prefix = this.cb_Prefix || 'jsonp_Callback_';
      /* seq_ID is appended to the cb_Prefix */
      this.seq_ID = 0;
      /* collect the requests for later inspection (maybe?) */
      this.requests = [];
    }

    make_Request(obj) {
      /* the call back function name, unique to this call */
      /* construct the url from the base_URL and the query object */
      var cb_Name, key, keys, request, url;
      cb_Name = this.cb_Prefix + this.seq_ID++;
      /* ADD 'CALLBACK' TO provided query object */
      obj.query.callback = cb_Name;
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
    }

  };

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
  JSONP_Request = class JSONP_Request {
    /* constructor */
    constructor(success, error, msec, cb_Name1, url1) {
      /* method callback() */
      this.callback = this.callback.bind(this);
      /* method send() */
      this.send = this.send.bind(this);
      this.success = success;
      this.error = error;
      this.msec = msec;
      this.cb_Name = cb_Name1;
      this.url = url1;
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

    callback(data) {
      window.clearTimeout(this.timeout);
      return this.success(data);
    }

    send() {
      window[this.cb_Name] = this.callback;
      this.timeout = window.setTimeout(this.error, this.msec);
      /* appending @elt triggers the call to fetch the jsonp script */
      return this.head.appendChild(this.elt);
    }

  };

  //!/usr/bin/env coffee
  /* Class Google_Maps_API */
  /**
   * A Google_Maps instance has methods for simple queries and searches
   * using the google maps javascript api
   * @constructor
   * @param {String} api_User_Agent - a string identifying the app to wikipedia
   */
  Google_Maps_API = class Google_Maps_API {
    /* constructor */
    constructor(key1) {
      /**
       * method handle_timeout()
       * a default timeout error handler for calls to method get() above
       * @param {Object} err - the error object
       */
      this.handle_Timeout = this.handle_Timeout.bind(this);
      /* method get() */
      this.get = this.get.bind(this);
      this.key = key1;
      this.jsonp = new JSONP_Controller('https://maps.googleapis.com/maps/api/js?');
    }

    handle_Timeout(err) {
      var msg;
      msg = "Google Maps unavailable.";
      console.log(msg);
      return console.log(err);
    }

    get(obj, options) {
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
    }

  };

  //!/usr/bin/env coffee
  /* Class Wikipedia_API */
  /**
   * A Wikipedia_API instance has methods for simple queries and searches
   * using the wikipedia api.
   * @constructor
   * @param {String} api_User_Agent - a string identifying the app to wikipedia
   */
  Wikipedia_API = class Wikipedia_API {
    /* constructor */
    constructor(api_User_Agent) {
      /**
       * method handle_timeout()
       * a default timeout error handler for calls to method get() above
       * @param {Object} err - the error object
       */
      this.handle_Timeout = this.handle_Timeout.bind(this);
      /* method get() */
      this.get = this.get.bind(this);
      /**
       * method query()
       * performs the ajax request for a 'query' action
       * @param {Object} obj - a query string object
       */
      this.query = this.query.bind(this);
      /**
       * method openSearch()
       * performs the ajax request for an 'opensearch' action
       * @param {Object} obj - a query string object
       */
      this.openSearch = this.openSearch.bind(this);
      this.api_User_Agent = api_User_Agent;
      this.jsonp = new JSONP_Controller('https://en.wikipedia.org/w/api.php?');
    }

    handle_Timeout(err) {
      var msg;
      msg = "Wikipedia search results unavailable.";
      console.log(msg);
      return console.log(err);
    }

    get(obj, query) {
      var request;
      request = this.jsonp.make_Request({
        query: query,
        success: obj.success,
        error: obj.error || this.handle_Timeout,
        msec: obj.msec || 3000
      });
      return request.send();
    }

    query(obj) {
      return this.get(obj, {
        action: 'query',
        format: 'json',
        prop: 'revisions',
        rvprop: 'content',
        titles: obj.title
      });
    }

    openSearch(obj) {
      return this.get(obj, {
        action: 'opensearch',
        format: 'json',
        search: obj.search_Str
      });
    }

  };

  //!/usr/bin/env/coffee
  /* Class Menu_View */
  /**
   * A Menu_View is a view of the neighborhood places as a list of clickable items
   * @constructor
   * @param {Neighborhood_Map} app - the main neighborhood map instance
   */
  Menu_View = class Menu_View {
    /* constructor */
    constructor(app) {
      /**
       * method toggle()
       * toggles the visibility of the menu
       */
      this.toggle = this.toggle.bind(this);
      this.app = app;
      this.menu_Element = document.getElementById('menu-view');
      this.menu_Button = document.getElementById('menu-button');
      this.hidden = ko.observable(false);
    }

    toggle() {
      return this.hidden(!this.hidden());
    }

  };

  /* Class Map_View */
  /**
   * A Map_View is a view of the neighbohood places on a map.
   * @constructor
   * @param {Neighborhood_Map} app - the main neighborhood map instance
   */
  Map_View = class Map_View {
    /* constructor */
    constructor(app) {
      this.init = this.init.bind(this);
      this.error = this.error.bind(this);
      this.app = app;
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

    init() {
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
    }

    error(err) {
      return window.alert("Google Maps is currently unavailable");
    }

  };

  Marker_View = (function() {
    var marker_Highlight_Icon, marker_Icon;

    class Marker_View {
      /* constructor */
      constructor(place1, map_View) {
        /* method display() */
        this.display = this.display.bind(this);
        /* method highlight() */
        this.highlight = this.highlight.bind(this);
        this.place = place1;
        this.map_View = map_View;
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

      display(show_marker) {
        return this.marker.setVisible(show_marker);
      }

      highlight(hl_true) {
        if (hl_true) {
          this.marker.setIcon(marker_Highlight_Icon);
          return this.marker.setZIndex(1001);
        } else {
          this.marker.setIcon(marker_Icon);
          return this.marker.setZIndex(1000);
        }
      }

    };

    marker_Icon = "https://maps.google.com/mapfiles/ms/icons/green-dot.png";

    marker_Highlight_Icon = "https://maps.google.com/mapfiles/ms/icons/blue-dot.png";

    return Marker_View;

  }).call(this);

  /* Class Info_View */
  /**
   * An Info_View is a view of a Place as a popup InfoWindow
   * @constructor
   * @param {Place} place
   * @param {Map_View} map_View
   * @param {Marker_View} marker_View
   */
  Info_View = class Info_View {
    /* constructor */
    constructor(place1, map_View, marker_View) {
      var s;
      /**
       * method display_Info()
       * helper function for method display_Wikipedia_Info()
       * @param {Object} obj - contains title, description and url
       */
      this.display_Info = this.display_Info.bind(this);
      /**
       * method display_Wikipedia_Info()
       * display either the info from wikipedia or an error message
       * @param {Boolean} show_marker - to display or not display
       */
      this.display_Wikipedia_Info = this.display_Wikipedia_Info.bind(this);
      /**
       * method display()
       * @param {Boolean} show_window - to display or not display
       */
      this.display = this.display.bind(this);
      this.place = place1;
      this.map_View = map_View;
      this.marker_View = marker_View;
      this.wikipedia_Info = void 0;
      s = '<span class="error-msg"> Wikipedia is currently unavailable. </span> <br>';
      this.error_Msg = s + '<span class="error-msg"> Please try again later. </span>';
      this.info_Window = new google.maps.InfoWindow({
        maxWidth: 250
      });
      this.info_Window.addListener('closeclick', this.place.click);
      this.place.show_info.subscribe(this.display);
    }

    display_Info(obj) {
      var s;
      s = '' + '<div class="info-window">' + '<h1 class="info-window-h1">' + obj.title + '</h1>' + '<p class="info-window-p">' + obj.description + '</p>' + '<a href="' + obj.url + '" target="_blank"> Wikipedia </a>' + '</div>';
      this.info_Window.setContent(s);
      return this.info_Window.open(this.map_View.map, this.marker_View.marker);
    }

    display_Wikipedia_Info() {
      if (typeof this.wikipedia_Info !== 'undefined') {
        return this.display_Info(this.wikipedia_Info);
      } else {
        return this.place.app.wikipedia.openSearch({
          search_Str: this.place.wikipedia_Title,
          success: ((data) => {
            this.wikipedia_Info = {
              title: data[1][0],
              description: data[2][0],
              url: data[3][0]
            };
            return this.display_Info(this.wikipedia_Info);
          }),
          error: (() => {
            return this.display_Info({
              title: this.place.name(),
              description: this.error_Msg,
              url: "https://en.wikipedia.org/"
            });
          })
        });
      }
    }

    display(show_Window) {
      if (show_Window) {
        return this.display_Wikipedia_Info();
      } else {
        return this.info_Window.close();
      }
    }

  };

  /* Class Place */
  /**
   * A Place is part of the view model.  It is constructed from a simple object
   * and is associated with a Marker_View, an Info_View and a
   * div.menu-list-item element as part of the Menu_View.
   * @constructor
   * @param {object} obj - a simple object containing the name, location and wikipedia title
   * @param {Neighborhood_Map} @app - the main app instance
   */
  Place = class Place {
    /* constructor */
    constructor(obj, app) {
      this.map_Ready = this.map_Ready.bind(this);
      /**
       * method click() handles all clicks whether on the menu items or
       * on the map markers and cycles through the states appropriately
       */
      this.click = this.click.bind(this);
      /**
       * method display
       * @param {Boolean} boolean_expr - to display or not display
       */
      this.display = this.display.bind(this);
      this.app = app;
      this.loc = obj.loc;
      this.name = ko.observable(obj.name);
      this.wikipedia_Title = obj.wikipedia_title;
      this.state = ko.observable(1);
      this.hidden = ko.computed(() => {
        return this.state() === 0;
      });
      this.visible = ko.computed(() => {
        return this.state() > 0;
      });
      this.selected = ko.computed(() => {
        return this.state() > 1;
      });
      //@show_info = ko.computed(=> @state() > 2)
      this.show_info = ko.computed(() => {
        return this.state() > 1;
      });
    }

    map_Ready() {
      this.marker_View = new Marker_View(this, this.app.map_View);
      return this.info_View = new Info_View(this, this.app.map_View, this.marker_View);
    }

    click() {
      var i, len, place, ref;
      ref = this.app.places();
      /* de-select all other places */
      for (i = 0, len = ref.length; i < len; i++) {
        place = ref[i];
        if (place !== this && place.state() > 1) {
          place.state(1);
        }
      }
      /* change to next state */
      //@state([1,2,3,2][@state()])
      this.state([1, 2, 1][this.state()]);
      /* hide the menu after selection when in cell phone mode. */
      if (window.innerWidth < 700) {
        return this.app.menu_View.hidden(true);
      }
    }

    display(bool_expr) {
      if (bool_expr) {
        return this.state(Math.max(1, this.state()));
      } else {
        return this.state(0);
      }
    }

  };

  /* Class Neighborhood_Map */
  /**
   * An instance of class Neighborhood_Map is the main app.
   * @constructor
   */
  Neighborhood_Map = class Neighborhood_Map {
    /* constructor */
    constructor() {
      /**
       * method map_Ready
       */
      this.map_Ready = this.map_Ready.bind(this);
      /**
       * method init
       * @param {Array} places - an array of simple place objects
       */
      this.init = this.init.bind(this);
      /**
       * method search
       * @param {String} pat - the patern to search for
       */
      this.search = this.search.bind(this);
      this.wikipedia = new Wikipedia_API('Map of Austin places');
      this.google_Maps = new Google_Maps_API("AIzaSyBjtVDpeVL8JzhYqCXt8d6E3bRanaNCXEo");
      this.places = ko.observableArray([]);
      this.menu_View = new Menu_View(this);
      this.map_View = new Map_View(this);
      this.app_Element = document.getElementById('neighborhood-map');
      this.search_Str = ko.observable('');
      this.search_Str.subscribe(this.search);
      ko.applyBindings(this, this.app_Element);
    }

    map_Ready() {
      var i, len, place, ref, results;
      ref = this.places();
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        place = ref[i];
        results.push(place.map_Ready());
      }
      return results;
    }

    init(places) {
      var i, len, obj, results;
      this.places([]);
      results = [];
      for (i = 0, len = places.length; i < len; i++) {
        obj = places[i];
        results.push(this.places.push(new Place(obj, this)));
      }
      return results;
    }

    search(pat) {
      var expr, i, len, place, ref, results;
      expr = RegExp(pat, 'i');
      ref = this.places();
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        place = ref[i];
        results.push(place.display(expr.test(place.name())));
      }
      return results;
    }

  };

  if (typeof window !== "undefined" && window !== null) {
    window.Neighborhood_Map = Neighborhood_Map;
    console.log("window.Neighborhood_Map installed");
  } else {
    console.log("could not install window.Neighborhood_Map");
  }

}).call(this);
