#!node_modules/.bin/coffee

###
 * source: build
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

fs = require('fs-extra')

# build-nodes is my own 'task runner'
# see src/tools/build-nodes
# 
bn = require('build-nodes')
        
class Neighborhood_Map_App

    constructor: ->

        @style = new bn.StyleSheet('style', 'css')
        @menu_icon = new bn.SVG('hamburger_icon', 'images')
        @search_icon = new bn.SVG('search_icon', 'images')

        @knockout = new bn.JavaScript('knockout-3.3.0', 'js')
        @coffee_script = new bn.JavaScript('coffee-script', 'js')
                
        @jsonp = new bn.CoffeeScript('jsonp', 'js')
        @google_maps_api = new bn.CoffeeScript('google_maps_api', 'js')
        @wikipedia_api = new bn.CoffeeScript('wikipedia_api', 'js')
        @austin_places = new bn.CoffeeScript('austin_places', 'js')
        @neighborhood_map = new bn.CoffeeScript('neighborhood_map', 'js')

        @index_template = new bn.HTML_Template('index', 'templates')

        @index_js = new bn.HTML_Page('index', @index_template, {
            styles: [ 
                @style.css.ref()
            ]
            client_libs: [
                @knockout.js.ref()
            ]
            client_scripts: [
                @jsonp.js.ref()
                @wikipedia_api.js.ref()
                @google_maps_api.js.ref()
                @austin_places.js.ref()
                @neighborhood_map.js.ref()
            ]
            menu_icon: [
                @menu_icon.svg.inline()
            ]
            search_icon: [
                @search_icon.svg.inline()
            ] 
        })

        @index_inline = new bn.HTML_Page('index_inline', @index_template, {
            styles: [ 
                @style.css.ref()
            ]
            client_libs: [
                @knockout.js.ref()
            ]
            client_scripts: [
                @jsonp.js.inline()
                @wikipedia_api.js.inline()
                @google_maps_api.js.inline()
                @austin_places.js.inline()
                @neighborhood_map.js.inline()
            ]
            menu_icon: [
                @menu_icon.svg.inline()
            ]
            search_icon: [
                @search_icon.svg.inline()
            ] 
        })

        @index_min = new bn.HTML_Minified_Page('index_min', @index_template, {
            styles: [ 
                @style.css_min.inline()
            ]
            client_libs: [
                @knockout.js.ref()
            ]
            client_scripts: [
                @jsonp.js_min.inline()
                @wikipedia_api.js_min.inline()
                @google_maps_api.js.inline()
                @austin_places.js_min.inline()
                @neighborhood_map.js_min.inline()
            ]
            menu_icon: [
                @menu_icon.svg.inline()
            ]
            search_icon: [
                @search_icon.svg.inline()
            ] 
        })

        @index_coffee = new bn.HTML_Page('index_coffee', @index_template, {
            styles: [ 
                @style.css.ref()
            ]
            client_libs: [ 
                @knockout.js.ref()
                @coffee_script.js.ref()
            ]
            client_scripts: [
                @jsonp.coffee.ref()
                @wikipedia_api.coffee.ref()
                @google_maps_api.js.ref()
                @austin_places.coffee.ref()
                @neighborhood_map.coffee.ref()
            ]
            menu_icon: [
                @menu_icon.svg.inline()
            ]
            search_icon: [
                @search_icon.svg.inline()
            ] 
        })

    clean: (dest = 'dist') =>
        fs.removeSync(dest)
        fs.mkdirsSync(dest + '/js')
        fs.mkdirsSync(dest + '/css')
        fs.mkdirsSync(dest + '/images')

    serve: (dir = 'dist', port = '8080') =>
        connect = require('connect')
        serveStatic = require('serve-static')
        connect().use(serveStatic(dir)).listen(port, ->
            console.log('Server running on ' + String(8080) + '...'))

    make: (dest = 'dist') =>

        fs.copySync('src/images/favicon.ico', dest + '/images/favicon.ico')
        
        tasks = [
            @jsonp
            @wikipedia_api
            @google_maps_api
            @austin_places
            @neighborhood_map
            @knockout
            @coffee_script
            @style
            @menu_icon
            @search_icon
            @index_coffee
            @index_js
            @index_inline
            @index_min
            ]

        start = Date.now()
        
        for task in tasks
            task.make('dist')

        console.log('\nBuild done in ' + String(Date.now()-start) + ' milliseconds.')

    
app = new Neighborhood_Map_App()
        
module.exports = {
    app: app
}
    
if not module.parent
    app.clean()
    app.make()