
## Udacity FEND Project 7 -1 Neighborhood Map

### Pre-requisites

This project requires the following programs to build from scratch:

 - node at least v4.2.1
 - npm  at least v3.5.3

You can download and build the website as follows:

```
$ git clone https://github.com/alcarruth/frontend-p7-1-neighborhood-map
$ cd frontend-p7-1-neighborhood-map
$ npm install
$ ./clean
$ ./build
```

This will build the project files and install them in the dist subdirectory.

### Project Overview and Usage

The title for the website is "Al's Austin Map".  It starts with a list of
about 20 locations in Austin, TX (the model) and utilizes the google maps api
and the wikipedia api to display markers for the locations on the map.  A
menu interface is also provided which provides a clickable list of the locations.

Clicking on either a marker or the menu item for a location will have exactly
the same effect, as the clicks are handled by the same click() method for the 
associated place. 

The first click will "select" the place, change the color of the marker and 
the appearance of the menu item.  Clicking a second time will trigger an
asynchronous JSONP request to wikipedia to get some basic information about
the place.  Once this async request is fulfilled a callback function pops
up a google maps InfoWindow containing the received information.

Note that the information retrieved for the InfoWindow is cached so that
subsequent requests to display this information will display the cached data
and not trigger another async JSONP request.

There is a hamburger icon in the upper left corner of the web page.  Clicking
this icon will toggle the visibility of the menu.  When the site is viewed 
from a smart phone or smaller tablet, the menu is large enough to be useable
and this obscures the map when the menu is visible.  So, for these smaller
devices, when a menu item is selected the menu automatically disappears
revealing the map.  On larger devices the menu remains visible.

At the top of the menu there is a magnifying glass icon and a text entry
field.  Any text entered here is used to filter the locations as you type
and update the menu and map appropriately, displaying only those locations
containing the typed text.


### Build Nodes


Stylesheets:
 - 
 - 
 - 

Scripts:
 - 
 - 
 - 

images:
 - 
 - 
 - 


### 


Extensive documentation can be found in the comments in these files, but here
is an overview.

####


```
window.pizzaApp = PizzaApp();
```

####

#### 

#### 

#### 

#### 

### Status


### License

ISC
