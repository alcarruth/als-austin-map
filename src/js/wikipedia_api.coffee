###*
 * source: wikipedia_api.coffee
###

___dummy___ = 'ignore this !-)'

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
    handle_timeout: (err) =>
        msg = "Wikipedia search results unavailable."
        console.log(msg)
        console.log(err)

    ### method display() ###
    get: (obj, query) =>
        request = @jsonp.make_request({
            query: query
            success: obj.success
            error: obj.error || @handle_timeout
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
            search: obj.search_str
        })

if window?
    window.Wikipedia = Wikipedia
