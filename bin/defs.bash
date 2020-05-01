#!/bin/bash

function run() {
    echo ${1}
    ${1}
}

function clean() {
    rm -rf dist/ build/
    mkdir -p dist/css dist/js dist/images
    mkdir -p build/css build/js build/coffee build/images build/html
}

function mk_als_austin_places_js() {
    cat src/als_austin_places.coffee src/init_map.coffee > build/coffee/als-austin-map.coffee
    pushd build > /dev/null
    coffee -c -o js/ coffee/als-austin-map.coffee
    popd > /dev/null
}

function mk_build() {
    pushd build > /dev/null
    cp ../src/index.html html/
    cp ../node_modules/neighborhood-map/dist/js/*.js js/
    cp ../node_modules/neighborhood-map/dist/css/*.css css
    cp ../node_modules/neighborhood-map/dist/images/* images
    popd > /dev/null
}

function mk_dist() {
    pushd build > /dev/null
    cp -r js/ ../dist/
    cp -r css/ ../dist/
    cp -r images/ ../dist/
    cp html/index.html ../dist/
    popd > /dev/null
}

function mk_all() {
    run clean
    run mk_als_austin_places_js
    run mk_build
    run mk_dist
}
