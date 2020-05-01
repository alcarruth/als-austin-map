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
bn = require('./build-nodes')
    
class Neighborhood_Map_App

  constructor: ->

    @style = new bn.StyleSheet('style', 'css')
    @menu_icon = new bn.SVG('hamburger_icon', 'images')
    @search_icon = new bn.SVG('search_icon', 'images')
    @init1()
    @init2()
    @init3()
    @init4()
    @init_index_js()
    @init_index_inline()
    @init_index_min()
 #   @init_index_coffee()

  init1: =>
    console.log("step 1")
    @knockout = new bn.JavaScript('knockout-3.3.0', 'js')
    @jsonp = new bn.CoffeeScript('jsonp', 'js')

  init2: =>
    console.log("step 2")
    @google_maps_api = new bn.CoffeeScript('google_maps_api', 'js')
    @wikipedia_api = new bn.CoffeeScript('wikipedia_api', 'js')

  init3: =>
    console.log("step 3")
    @austin_places = new bn.CoffeeScript('austin_places', 'js')
    @neighborhood_map = new bn.CoffeeScript('neighborhood_map', 'js')

  init4: =>
    console.log("step 4")
    @index_template = new bn.HTML_Template('index', 'templates')

  init_index_js: =>
    console.log("init_index_js()")
    
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

    
  init_index_inline: =>
    console.log("init_index_inline()")
    
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


  init_index_min: =>
    console.log("init_index_min()")

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


  init_index_coffee: =>
    console.log("init_index_coffee()")
    
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
    
    tasks = {
      jsonp: @jsonp
      wikipedia_api: @wikipedia_api
      google_maps_api: @google_maps_api
      austin_places: @austin_places
      neighborhood_map: @neighborhood_map
      knockout: @knockout
#      coffeescript: @coffeescript
      style: @style
      menu_icon: @menu_icon
      search_icon: @search_icon
#      index_coffee: @index_coffee
      index_js: @index_js
      index_inline: @index_inline
      index_min: @index_min
      }

    start = Date.now()
    
    for name, task of tasks
      console.log "Task #{name}: #{task.toString()}"
      task.make(dest)

    console.log('\nBuild done in ' + String(Date.now()-start) + ' milliseconds.')

  
app = new Neighborhood_Map_App()
    
module.exports = {
  app: app
}
  
if not module.parent
  app.clean()
  app.make()
