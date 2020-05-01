

### austin_places is a JSON string which serves as our model ###
austin_Places_JSON = '[{"name":"Auditorium Shores","wikipedia_title":"Auditorium Shores","page_id":18928372,"loc":{"lat":30.2627167,"lng":-97.7515303}},{"name":"Barton Springs Pool","wikipedia_title":"Barton Springs Pool","page_id":994682,"loc":{"lat":30.264293,"lng":-97.771109}},{"name":"Deep Eddy Pool","wikipedia_title":"Deep Eddy Pool","page_id":3890635,"loc":{"lat":30.276515,"lng":-97.7732058}},{"name":"Mount Bonnell","wikipedia_title":"Mount Bonnell","page_id":1238172,"loc":{"lat":30.3214561,"lng":-97.7732058}},{"name":"Zilker Park","wikipedia_title":"Zilker Park","page_id":165971,"loc":{"lat":30.2669624,"lng":-97.772859}},{"name":"Driskill Hotel","wikipedia_title":"Driskill Hotel","page_id":4064917,"loc":{"lat":30.2681619,"lng":-97.7416996}},{"name":"Texas State Capitol","wikipedia_title":"Texas State Capitol","page_id":503403,"loc":{"lat":30.2746652,"lng":-97.7403505}},{"name":"Texas Governor\'s Mansion","wikipedia_title":"Texas Governor\'s Mansion","page_id":5723219,"loc":{"lat":30.2727527,"lng":-97.7430868}},{"name":"Treaty Oak","wikipedia_title":"Treaty Oak (Austin, Texas)","page_id":438722,"loc":{"lat":30.2712406,"lng":-97.7555901}},{"name":"University of Texas","wikipedia_title":"University of Texas at Austin","page_id":32031,"loc":{"lat":30.2849185,"lng":-97.7340567}},{"name":"French Legation","wikipedia_title":"French Legation","page_id":5910542,"loc":{"lat":30.2670255,"lng":-97.7319951}},{"name":"Antone\'s","wikipedia_title":"Clifford Antone","page_id":5277250,"loc":{"lat":30.2660481,"lng":-97.7425889}},{"name":"Austin City Limits","wikipedia_title":"Austin City Limits","page_id":174839,"loc":{"lat":30.2655623,"lng":-97.7473038}},{"name":"Blanton Museum of Art","wikipedia_title":"Blanton Museum of Art","page_id":4339388,"loc":{"lat":30.2810198,"lng":-97.7374621}},{"name":"Bullock Texas State History Museum","wikipedia_title":"Bullock Texas State History Museum","page_id":6031876,"loc":{"lat":30.2802905,"lng":-97.7390746}},{"name":"Elisabet Ney Museum","wikipedia_title":"Elisabet Ney Museum","page_id":4657074,"loc":{"lat":30.30668,"lng":-97.7262735}},{"name":"Harry Ransom Center","wikipedia_title":"Harry Ransom Center","page_id":946273,"loc":{"lat":30.2843406,"lng":-97.7412267}},{"name":"LBJ Presidential Library","wikipedia_title":"Lyndon Baines Johnson Library and Museum","page_id":1724361,"loc":{"lat":30.2858787,"lng":-97.7292372}},{"name":"Mexic-Arte Museum","wikipedia_title":"Mexic-Arte Museum","page_id":6707654,"loc":{"lat":30.26684,"lng":-97.7428}},{"name":"O. Henry Museum","wikipedia_title":"William Sidney Porter House","page_id":9869149,"loc":{"lat":30.2656736,"lng":-97.7391424}},{"name":"South Austin Museum of Popular Culture","wikipedia_title":"South Austin Museum of Popular Culture","page_id":15103570,"loc":{"lat":30.2517604,"lng":-97.7650138}}]'



### Class JSONP_Controller ###
###*
 * A JSONP_Controller instance can be used to make a jsonp request to an api server.
 * @constructor
 * @param {string} base_URL - the base url for the server
 * @param {string} cb_Prefix - used in naming the jsonp callback function
###
class JSONP_Controller

  ### constructor ###
  constructor: (@base_URL, @cb_Prefix) ->
    @cb_Prefix = @cb_Prefix || 'jsonp_Callback_'
    ### seq_ID is appended to the cb_Prefix ###
    @seq_ID = 0
    ### collect the requests for later inspection (maybe?) ###
    @requests = []
    
  ###*
   * method make_Request()
   * returns a JSONP_Request object
   * @param {object} obj - query, success, error, msec
  ###
  make_Request: (obj) =>

    ### the call back function name, unique to this call ###
    cb_Name = @cb_Prefix + @seq_ID++
    
    ### ADD 'CALLBACK' TO provided query object ###
    obj.query.callback = cb_Name

    ### construct the url from the base_URL and the query object ###
    url = @base_URL
    keys = Object.keys(obj.query)
    url += (key+'='+obj.query[key] for key in keys).join('&')
    url = encodeURI(url)

    request = new JSONP_Request(obj.success, obj.error, obj.msec, cb_Name, url)
    @requests.push(request)
    return request





### Class JSONP_Request ###
###*
 * A JSONP_Request object is used to make a jsonp request to an api server.
 * @constructor
 * @param {function} success - executed upon successful jsonp response
 * @param {function} error - executed upon timeout
 * @param {int} msec - timeout delay in milliseconds
 * @param {string} cb_Name 
 * @param {string} url - the url for jsonp call
###
class JSONP_Request

  ### constructor ###
  constructor: (@success, @error, @msec, @cb_Name, @url) ->
    
    ### the parent node to be ###
    @head = document.getElementsByTagName('head')[0]
    
    ### the script element that enables this request ###
    @elt = document.createElement('script')
    @elt.type = 'text/javascript'
    @elt.async = true
    @elt.src = @url

    ### the below might be useful later, idk ###
    @elt.id = @cb_Name
    @elt.className = 'jsonp-request'
    @elt.request = this

  ### method callback() ###
  callback: (data) =>
    window.clearTimeout(@timeout)
    @success(data)

  ### method send() ###
  send: =>
    window[@cb_Name] = @callback
    @timeout = window.setTimeout(@error, @msec)
    ### appending @elt triggers the call to fetch the jsonp script ###
    @head.appendChild(@elt)





### Class Google_Maps ###
###*
 * A Google_Maps instance has methods for simple queries and searches
 * using the google maps javascript api
 * @constructor
 * @param {String} api_User_Agent - a string identifying the app to wikipedia
###
class Google_Maps

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





### Class Wikipedia ###
###*
 * A Wikipedia instance has methods for simple queries and searches
 * using the wikipedia api.
 * @constructor
 * @param {String} api_User_Agent - a string identifying the app to wikipedia
###
class Wikipedia

  ### constructor ###
  constructor: (@api_User_Agent) ->
    @jsonp = new JSONP_Controller('https://en.wikipedia.org/w/api.php?')

  ###*
   * method handle_timeout()
   * a default timeout error handler for calls to method get() above
   * @param {Object} err - the error object
  ###
  handle_Timeout: (err) =>
    msg = "Wikipedia search results unavailable."
    console.log(msg)
    console.log(err)

  ### method get() ###
  get: (obj, query) =>
    request = @jsonp.make_Request({
      query: query
      success: obj.success
      error: obj.error || @handle_Timeout
      msec: obj.msec || 3000
    })
    request.send()

  ###*
   * method query()
   * performs the ajax request for a 'query' action
   * @param {Object} obj - a query string object
  ###
  query: (obj) =>
    @get(obj, { 
      action: 'query'
      format: 'json'
      prop: 'revisions'
      rvprop: 'content'
      titles: obj.title
    })

  ###*
   * method openSearch()
   * performs the ajax request for an 'opensearch' action
   * @param {Object} obj - a query string object
  ###
  openSearch: (obj) =>
    @get(obj, {
      action: 'opensearch'
      format: 'json'
      search: obj.search_Str
    })





### Class Menu_View ###
###*
 * A Menu_View is a view of the neighborhood places as a list of clickable items
 * @constructor
 * @param {Neighborhood_Map} app - the main neighborhood map instance
###
class Menu_View

  ### constructor ###
  constructor: (@app) ->
    @menu_Element = document.getElementById('menu-view')
    @menu_Button = document.getElementById('menu-button')
    @hidden = ko.observable(false)

  ###*
   * method toggle()
   * toggles the visibility of the menu
  ###
  toggle: => @hidden(not @hidden())





### Class Map_View ###
###*
 * A Map_View is a view of the neighbohood places on a map.
 * @constructor
 * @param {Neighborhood_Map} app - the main neighborhood map instance
###
class Map_View

  ### constructor ###
  constructor: (@app) ->
    @map_Element = document.getElementById('map-view')
    @gm_request = @app.google_Maps.get({
      query: { libraries: 'places' }
      success: @init
      error: @error
      msec: 3000
    })

  init: =>
    @map = new google.maps.Map( @map_Element, {
      center: { lat: 30.2712406, lng: -97.7555901 }, 
      scrollwheel: true,
      zoom: 13,
      disableDefaultUI: true,
      callback: @error
    })
    @app.map_Ready()
      
  error: (err) =>
    window.alert("Google Maps is currently unavailable")





### Class Marker_View ###
###*
 * A Marker_View is a view of a place as a map marker on the map.
 * @constructor
 * @param {PLace} place - an instance of the Place class 
 * @param {Map_View} map_View - an instance of the Map_View class 
###
class Marker_View

  marker_Icon = "https://maps.google.com/mapfiles/ms/icons/green-dot.png"
  marker_Highlight_Icon = "https://maps.google.com/mapfiles/ms/icons/blue-dot.png"

  ### constructor ###
  constructor: (@place, @map_View) ->
    @marker = new google.maps.Marker({
      position: @place.loc,
      optimized: false,
      zIndex:1000,
      map: @map_View.map,
      title: @place.name(),
      icon: marker_Icon,
      opacity: 1.0
    })
    @marker.addListener('click', @place.click)
    @place.visible.subscribe(@display)
    @place.selected.subscribe(@highlight)

  ### method display() ###
  display: (show_marker) =>
    @marker.setVisible(show_marker)

  ### method highlight() ###
  highlight: (hl_true) =>
    if hl_true
      @marker.setIcon(marker_Highlight_Icon)
      @marker.setZIndex(1001)
    else
      @marker.setIcon(marker_Icon)
      @marker.setZIndex(1000)




### Class Info_View ###
###*
 * An Info_View is a view of a Place as a popup InfoWindow
 * @constructor
 * @param {Place} place
 * @param {Map_View} map_View
 * @param {Marker_View} marker_View
###
class Info_View

  ### constructor ###
  constructor: (@place, @map_View, @marker_View) ->
    @wikipedia_Info = undefined
    s = '<span class="error-msg"> Wikipedia is currently unavailable. </span> <br>'
    @error_Msg = s + '<span class="error-msg"> Please try again later. </span>'
    @info_Window = new google.maps.InfoWindow( maxWidth: 250 )
    @info_Window.addListener('closeclick', @place.click)
    @place.show_info.subscribe(@display)

  ###*
   * method display_Info()
   * helper function for method display_Wikipedia_Info()
   * @param {Object} obj - contains title, description and url
  ###
  display_Info: (obj) =>
    s = '' +
      '<div class="info-window">' +
      '<h1 class="info-window-h1">' + obj.title + '</h1>' +
      '<p class="info-window-p">' + obj.description + '</p>' + 
      '<a href="' + obj.url + '" target="_blank"> Wikipedia </a>' +
      '</div>'
    @info_Window.setContent(s)
    @info_Window.open(@map_View.map, @marker_View.marker)

  ###*
   * method display_Wikipedia_Info()
   * display either the info from wikipedia or an error message
   * @param {Boolean} show_marker - to display or not display
  ###
  display_Wikipedia_Info: =>
    if typeof(@wikipedia_Info) != 'undefined'
      @display_Info(@wikipedia_Info)
    else
      @place.app.wikipedia.openSearch( {
        search_Str: @place.wikipedia_Title,
        success: ((data) =>
          @wikipedia_Info = {
            title: data[1][0],
            description: data[2][0]
            url: data[3][0]
          }
          @display_Info(@wikipedia_Info)),
        error: (=>
          @display_Info({
            title: @place.name(),
            description: @error_Msg,
            url: "https://en.wikipedia.org/"}))
        })

  ###*
   * method display()
   * @param {Boolean} show_window - to display or not display
  ###
  display: (show_Window) =>
    if show_Window
      @display_Wikipedia_Info()
    else
      @info_Window.close()





### Class Place ###
###*
 * A Place is part of the view model.  It is constructed from a simple object
 * and is associated with a Marker_View, an Info_View and a
 * div.menu-list-item element as part of the Menu_View.
 * @constructor
 * @param {object} obj - a simple object containing the name, location and wikipedia title
 * @param {Neighborhood_Map} @app - the main app instance
###
class Place

  ### constructor ###
  constructor: (obj, @app) ->
    @loc = obj.loc
    @name = ko.observable(obj.name)
    @wikipedia_Title = obj.wikipedia_title
    @state = ko.observable(1)
    @hidden = ko.computed(=> @state() == 0)
    @visible = ko.computed(=> @state() > 0)
    @selected = ko.computed(=> @state() > 1)
    #@show_info = ko.computed(=> @state() > 2)
    @show_info = ko.computed(=> @state() > 1)

  map_Ready: =>
    @marker_View = new Marker_View(this, @app.map_View)
    @info_View = new Info_View(this, @app.map_View, @marker_View)
    
  ###*
   * method click() handles all clicks whether on the menu items or
   * on the map markers and cycles through the states appropriately
  ###
  click: =>
    
    ### de-select all other places ###
    for place in @app.places()
      if place != this and place.state() > 1
        place.state(1)
        
    ### change to next state ###
    #@state([1,2,3,2][@state()])
    @state([1,2,1][@state()])

    ### hide the menu after selection when in cell phone mode. ###
    if window.innerWidth < 700
      @app.menu_View.hidden(true)

  ###*
   * method display
   * @param {Boolean} boolean_expr - to display or not display
  ###
  display: (bool_expr) =>
    if bool_expr
      @state(Math.max(1, @state()))
    else
      @state(0)




### Class Neighborhood_Map ###
###*
 * An instance of class Neighborhood_Map is the main app.
 * @constructor
###
class Neighborhood_Map

  ### constructor ###
  constructor: ->
    @wikipedia = new Wikipedia('Map of Austin places')
    @google_Maps = new Google_Maps("AIzaSyBjtVDpeVL8JzhYqCXt8d6E3bRanaNCXEo")
    @places = ko.observableArray([])
    @menu_View = new Menu_View(this)
    @map_View = new Map_View(this)
    @app_Element = document.getElementById('neighborhood-map')
    @search_Str = ko.observable('')
    @search_Str.subscribe(@search)
    ko.applyBindings( this, @app_Element)

  ###*
   * method map_Ready
  ###
  map_Ready: =>
    for place in @places()
      place.map_Ready()
      
  ###*
   * method init
   * @param {JSON} places_JSON - a json string representing an array of simple place objects
  ###
  init: (@places_JSON) =>
    @places([])
    for obj in JSON.parse(@places_JSON)
      @places.push(new Place(obj, this))

  ###*
   * method search
   * @param {String} pat - the patern to search for
  ###
  search: (pat) =>
    expr = RegExp(pat,'i')
    for place in @places()
      place.display(expr.test(place.name()))


init = ->
  neighborhood_Map = new Neighborhood_Map()
  neighborhood_Map.init(austin_Places_JSON)
  window.neighborhood_Map = neighborhood_Map

if window?

  if document.readyState == 'complete'
    init()
  else
    document.onreadystatechange = ->
      if document.readyState == 'complete'
        init()
        
