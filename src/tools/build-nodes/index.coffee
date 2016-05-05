### Module build-nodes ###
### build-nodes/index.coffee ###

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

fs = require('fs-extra')
coffee = require('coffee-script')
uglify_js = require('uglify-js')
minify = require('minify')
Clean_CSS = require('clean-css')
htmlmin = require('htmlmin')
mustache = require('mustache')
js_beautify = require('js-beautify')

beautify_comments = (->
    re = new RegExp('\\*/\n+','gm')
    (s) -> s.replace(re, '*/\n'))()

###
 * TODO: How much of the Udacity Style Guide compliance
 *       might I be able to automate here?
###


beautify = {
    js: (x)-> beautify_comments(js_beautify(x))
    min_js: (x)->x
    css: js_beautify.css
    min_css: (x)->x
    html: js_beautify.html
    coffee: (x)->x
    svg: (x)->x
}

minify = {
    js: (s) -> uglify_js.minify(s, { fromString: true} ).code
    min_js: (x)->x
    css: (s) -> (new Clean_CSS()).minify(s).styles
    html: htmlmin
    coffee: (x)->x
    svg: (x)->x
}

###
 * TODO:
 * I need some utitlity element tag functions here that can automate
 * properties, e.g. 'async' property for a <script> tag
###


### Simple object render ###
###*
 * Object render is used to render the html for a resource,
 * either by reference or by inclusion.
 * Example usage:
 *  - render.js.ref('js/jquery.js')
 *  - render.css.inline(css_str)
###
render = 
    js:
        ref: (path) -> '<script src="' + path + '"> </script>\n'
        inline: (str) -> '<script>\n' + str + '\n</script>\n'
    min_js:
        ref: (path) -> '<script src="' + path + '"> </script>\n'
        inline: (str) -> '<script>\n' + str + '\n</script>\n'
    coffee:
        ref: (path) -> '<script src="' + path + '" type="text/coffeescript"> </script>\n'
        inline: (str) -> '<script type="text/coffeescript">\n' + str + '\n</script>\n'
    css:
        ref: (path) -> '<link rel="stylesheet" href="' + path + '">\n'
        inline: (str) -> '<style>\n' + str + '\n</style>\n'
    min_css:
        ref: (path) -> '<link rel="stylesheet" href="' + path + '">\n'
        inline: (str) -> '<style>\n' + str + '\n</style>\n'
    svg:
        ref: (path) -> '<img src="' + path + '" alt="' + path + '">\n'
        inline: (str) ->  str


### Class Source ###
###*
 * A Source node is a caching node which reads a file to supply its data.
 * @constructor
 * @param {string} name - the file's base name
 * @param {string} dir - the file's directory
 * @param {string} ext - the file's extension
 * @param {string} rtype - render type
 * @method {function} get - return value
 * @method {function} path - return file path
 * @method {function} fill - fetch the value
 * @method {function} ref - return html reference
 * @method {function} inline - return inline html
 * @method {function} make - make the target
###
class Source
    
    ### constructor() ###
    constructor: (@name, @dir, @ext, @rtype) ->
        @x = undefined
        @rtype = @rtype || @ext
        @render = render[@rtype]
        
    ### method get() ###
    get: =>
        @fill() if @x == undefined
        return @x
        
    ### method path() ###
    path: => [@dir, '/', @name, '.', @ext].join('')

    ### method fill() ###
    fill: => @x = fs.readFileSync('src/' + @path(), 'utf-8')

    ### method ref() ###
    ref: => @render.ref(@path())
    
    ### method inline() ###
    inline: => @render.inline(@get())

    ### method make() ###
    make: (dest) =>
        path = dest + '/' + @path()
        console.log(@path())
        fs.writeFileSync(path, beautify[@rtype](@get()))


### Class Apply ###
###*
 * An Apply node is a caching node which depends on an input node
 * and applies a function fun() to produce its data.
 * @constructor
 * @param {string} name - the node's base name
 * @param {function} fun - the function to apply to the input
 * @param {string} input - an input node
 * @param {string} dir - the file's directory
 * @param {string} ext - the file's extension
 * @param {string} rtype - render type
 * @method {function} get - return value
 * @method {function} path - return file path
 * @method {function} fill - fetch the value
 * @method {function} ref - return html reference
 * @method {function} inline - return inline html
 * @method {function} make - make the target
###
class Apply

    ### constructor() ###
    constructor: (@name, @fun, @input, @dir, @ext, @rtype) ->
        @x = undefined
        @rtype = @rtype || @ext
        @render = render[@rtype]
        
    ### method get() ###
    get: =>
        @fill() if @x == undefined
        return @x
        
    ### method path() ###
    path: => [@dir, '/', @name, '.', @ext].join('')

    ### method fill() ###
    fill: => @x = @fun(@input.get())

    ### method ref() ###
    ref: => @render.ref(@path())

    ### method inline() ###
    inline: => @render.inline(@get())

    ### method make() ###
    make: (dest) =>
        path = dest + '/' + @path()
        console.log(@path())
        fs.writeFileSync(path, beautify[@rtype](@get()))


### Class CoffeeScript ###
###*
 * A CoffeeScript instance contains three caching nodes:
 * one for coffee, one for js and one for minified js.
 * @constructor
 * @param {string} name - the node's base name
 * @param {string} dir - the file's directory
 * @method {function} make - make all three targets
###
class CoffeeScript

    ### constructor() ###
    constructor: (@name, @dir) ->
        @coffee = new Source(@name, @dir, 'coffee')
        @js = new Apply(@name, @compile, @coffee, @dir, 'js')
        @js_min = new Apply(@name, minify.js, @js, @dir, 'min.js', 'min_js')

    ### method compile() ###
    compile: (src) =>
        coffee.compile(src)

    ### method make() ###
    make: (dest = 'dist/') =>
        @coffee.make(dest)
        @js.make(dest)
        path = [@dir, '/', @name, '.js'].join('')
        fs.copySync(dest + path, 'src/' + path
        @js_min.make(dest)


### Class JavaScript ###
###*
 * A JavaScript instance contains two caching nodes:
 * one for js and one for minified js.
 * @constructor
 * @param {string} name - the node's base name
 * @param {string} dir - the file's directory
 * @method {function} make - make both targets
###
class JavaScript

    ### constructor() ###
    constructor: (@name, @dir) ->
        @js = new Source(@name, @dir, 'js', 'min_js')
        @js_min = new Apply(@name, minify_js, @js, @dir, 'min.js', 'js')

    ### method make() ###
    make: (dest = 'dist/') =>
        @js.make(dest)
        fs.copySync(dest + @dir + @name + '.'
        @js_min.make(dest)


### Class JavaScriptLib ###
###*
 * A JavaScriptLib instance contains one caching node
 * @constructor
 * @param {string} name - the node's base name
 * @param {string} dir - the file's directory
 * @method {function} make - make both targets
###
class JavaScriptLib

    ### constructor() ###
    constructor: (@name, @dir) ->
        @js = new Source(@name, @dir, 'js', 'min_js')

    ### method make() ###
    make: (dest = 'dist/') =>
        @js.make(dest)



### Class StyleSheet ###
###*
 * A StyleSheet instance contains two caching nodes:
 * one for css and one for minified css.
 * @constructor
 * @param {string} name - the node's base name
 * @param {string} dir - the file's directory
 * @method {function} make - make both targets
###
class StyleSheet

    ### constructor() ###
    constructor: (@name, @dir) ->
        @css = new Source(@name, @dir, 'css')
        @css_min = new Apply(@name, minify.css, @css, @dir, 'min.css', 'min_css')

    ### method make() ###
    make: (dest = 'dist/') =>
        @css.make(dest)
        @css_min.make(dest)
        

### Class SVG ###
###*
 * An SVG instance is a Source node for an svg image.
 * @constructor
 * @param {string} name - the node's base name
 * @param {string} dir - the file's directory
 * @method {function} make - make target
###
class SVG

    ### constructor() ###
    constructor: (@name, @dir) ->
        @svg = new Source(@name, @dir, 'svg', 'svg')

    ### method make() ###
    make: (dest) => @svg.make(dest)


### Class QueryURL ###
###*
 * QueryURL
 * @constructor
 * @param {string} base_url - the base url
 * @param {object} query - args for query string 
 * @method {function} get - return full url
###
class QueryURL

    ### constructor() ###
    constructor: (@base_url, @query, @options) ->
        @query = @query || {}
        @options = @options || {}
        @js = { ref: =>
            obj = (k: v for k,v of @options)
            obj.src = @get()
            s = '<script'
            for k,v of obj
                s += ' ' + String(k) + '="' + String(v) + '"' 
            s += '> </script>\n'
            return s
        }
        
    ### method get() ###
    get: =>
        url = @base_url
        if @query != {}
            url += '?' + (key+'='+val for key, val of @query).join('&')
            url = encodeURI(url)
        return url


### Class HTML_Template ###
###*
 * An HTML_Template
 * @constructor
 * @param {string} name - the template's base name
 * @param {string} dir - the template's directory
 * @method {function} render - render using supplied obj
 * @method {function} render_min - minify render
###
class HTML_Template

    ### constructor() ###
    constructor: (@name, @dir) ->
        @source = new Source(@name, @dir, 'html')

    ### method render() ###
    render: (obj) =>
        options = {}
        #options[k] = v.join('') for k,v of obj
        options[k] = v for k,v of obj
        mustache.render(@source.get(), options)


### HTML_Page ###
###*
 * An HTML_Page instance contains two caching nodes:
 * one for css and one for minified css.
 * @constructor
 * @param {string} name - the node's base name
 * @param {string} template - a mustache template
 * @param {object} data - namespace for template
 * @method {function} make - render and make target
###
class HTML_Page

    ### constructor() ###
    constructor: (@name, @template, @data) ->

    ### method make() ###
    make: (dest) =>
        fname = @name + '.html'
        x = @template.render(@data)
        fs.writeFileSync(dest + '/' + fname, x)
        console.log(fname)

### HTML_Minified_Page ###
###*
 * An HTML_Minified_Page instance contains two caching nodes:
 * one for css and one for minified css.
 * @constructor
 * @param {string} name - the node's base name
 * @param {string} template - a mustache template
 * @param {object} data - namespace for template
 * @method {function} make - render and make target
###
class HTML_Minified_Page

    ### constructor() ###
    constructor: (@name, @template, @data) ->

    ### method make() ###
    make: (dest) =>
        fname = @name + '.html'
        x = minify.html(@template.render(@data))
        fs.writeFileSync(dest + '/' + fname, x)
        console.log(fname)


module.exports = {
    Source: Source
    Apply: Apply
    CoffeeScript: CoffeeScript
    JavaScript: JavaScript
    StyleSheet: StyleSheet
    SVG: SVG
    QueryURL: QueryURL
    HTML_Template: HTML_Template
    HTML_Page: HTML_Page
    HTML_Minified_Page: HTML_Minified_Page
}
    
