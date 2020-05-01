#!/bin/bash

function clean() {
    rm -r dist/ build/
    mkdir -p dist/css dist/js dist/images
    mkdir -p build/css build/js build/coffee build/images build/html
}

function mk_als_austin_map_coffee() {
    pushd src/coffee
    cat \
        austin_places.coffee \
        jsonp_controller.coffee \
        google_maps_api.coffee \
        wikipedia_api.coffee \
        neighborhood_map.coffee \
        > ../../build/coffee/als-austin-map.coffee
    popd
}

function mk_als_austin_map_js() {
    mk_als_austin_map_coffee
    pushd build
    coffee -c -o js/ coffee/als-austin-map.coffee
    popd
}

function mk_build() {
    mk_als_austin_map_js
    pushd build
    cp -r ../src/js .
    cp -r ../src/css .
    cp -r ../src/images .
    cp ../src/index.html html/
    cp ../node_modules/knockout/build/output/knockout-latest.js js/knockout.js
    popd
}

function mk_dist() {
    clean
    mk_build
    pushd build
    cp -r js/ ../dist/
    cp -r css/ ../dist/
    cp -r images/ ../dist/
    cp html/index.html ../dist/
    popd
}

