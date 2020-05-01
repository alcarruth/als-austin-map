#!/usr/bin/env coffee


init = ->
  neighborhood_Map = new Neighborhood_Map()
  neighborhood_Map.init(als_austin_places)
  window.neighborhood_Map = neighborhood_Map

if window?

  if document.readyState == 'complete'
    init()
  else
    document.onreadystatechange = ->
      if document.readyState == 'complete'
        init()
        

