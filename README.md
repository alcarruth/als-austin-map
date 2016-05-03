
## Udacity FEND Project 7 -1 Neighborhood Map

### Quick Start

This project requires the following programs to build from scratch:

 - [`nodejs`](https://nodejs.org/en/) - version 4.2.1 or greater.
 - [`npm`](https://www.npmjs.com/) - version 3.5.3 or greater.

If these requirements are satisfied, you can download and build the 
Neighborhood Maps App as follows:

```
$ git clone https://github.com/alcarruth/frontend-p7-1-neighborhood-map
$ cd frontend-p7-1-neighborhood-map
$ npm install
$ ./build
```

This will build the project files and install them in the `dist` subdirectory.
A simple server is included in the file `serve` which can be run as follows:

```
$ ./serve
```

Now point your browser to [`http://localhost:8080/index.html'].

Also, to see different versions of the app which are produced by the
build command, have a look at [`http://localhost:8080/index_coffee.html']
and [`http://localhost:8080/index_min.html'].
These demonstrate the flexibility of the build approach used.


### Project Overview and Usage

The title for the website is "Al's Austin Map".  It starts with a list of
about 20 locations in Austin, TX (the model) and utilizes the 
[Google Maps API](https://developers.google.com/maps/)
and the [Wikipedia API](https://www.mediawiki.org/wiki/API:Main_page)
to display markers for the locations on the map.  A
menu interface is also provided which provides a clickable list of the locations.

Clicking on either a marker or the menu item for a location will have exactly
the same effect, as the clicks are handled by the same `click()` method for the 
associated place. 

The first click will "select" the place, change the color of the marker and 
the appearance of the menu item.  Clicking a second time will trigger an
asynchronous JSONP request to wikipedia to get some basic information about
the place.  Once this async request is fulfilled a `callback` function pops
up a google maps `InfoWindow` containing the received information.

Note that the information retrieved for the `InfoWindow` is cached so that
subsequent requests to display this information will display the cached data
and not trigger another async JSONP request.

There is a hamburger icon in the upper left corner of the web page.  Clicking
this icon will toggle the visibility of the menu.  When the site is viewed 
from a smart phone or smaller tablet, the menu is large enough to be useable
and this obscures the map when the menu is visible.  So, for these smaller
devices, when a menu item is selected the menu automatically disappears
revealing the map.  (On larger devices the menu remains visible.)

At the top of the menu there is a magnifying glass icon and a text entry
field.  Any text entered here is used to filter the locations as you type
and update the menu and map appropriately, displaying only those locations
containing the typed text.

### CoffeeScript

This site was built using [CoffeeScript](http://coffeescript.org/), 
both for generation of the javascript and for the build process.  
Care was taken to ensure that meaningful comments
survived the compilation process intact and that the produced JavaScript 
satisfied the style requirements and JSHint.

It is my belief that this produced much more comprehensible code than using
JavaScript straight away.  CoffeeScript offers a clean object oriented syntax
that encourages thinking about the problem at hand at a more abstract level,
while avoiding some of the pitfalls of a pure JavaScript approach.

In particular, I believe the use of an unbound `this` reference is bad mojo. If 
you have a look at the CoffeeScript in this project, note that while constructors
and a few simple functions are defined using the single arrow (`->`) all of
the method definitions are defined using the double arrow (`=>`) which binds `this`
to the instance of the class being defined.

### Build Tools

I wanted to be able to generate multiple `index.html` targets from the same source,
some with inlined [images|script|css] and some with references or links to those
resources.  Likewise, I wanted the flexibility to generate pretty
or minified [images|scripts|css].  

I tried [gulp](http://gulpjs.com/) but found it too 'linear' to easily 
combine two previously computed dependencies to produce a new target.  
And you have to do some song and dance just to compute two things sequentially. 
Really?  This ability has been a feature of programming languages since day one.
So I tried [grunt](http://gruntjs.com/) with a little more success, but 
unfortunately I still had trouble getting it to do what I wanted.

So I tried writing a build script in CoffeeScript and had more success.  Eventually
I separated the project specific build code from the more general stuff.  The results
can be seen in the file [`build`](https://github.com/alcarruth/frontend-p7-1-neighborhood-map/blob/master/build)
in the root directory, and the general code in [`src/tools/build-nodes`](https://github.com/alcarruth/frontend-p7-1-neighborhood-map/blob/master/src/tools/build-nodes/index.coffee). Perhaps I can break this out into its own repository.


### JSONP

JSONP is a strange animal.  After taking the Introduction to AJAX course and 
seeing a number of other explanations on the web, I was still confused.  So
at first I solved the problem by using jQuery's `$.ajax` function and setting
the data type to 'jsonp'.  This works great but jQuery is not a small library
and I didn't feel right loading it just for this one function.

So, I rolled my own, object-oriented, solution which can be found in 
[`source/js/jsonp.coffee`](https://github.com/alcarruth/frontend-p7-1-neighborhood-map/blob/master/src/js/jsonp.coffee)
I believe it to be simple, general and intelligible.  (And now I understand how JSONP
actually works!)

### Knockout

### Architecture

### License

The code in this repository is licensed under the [ISC](https://opensource.org/licenses/ISC) license of the Open Source Initiative.
