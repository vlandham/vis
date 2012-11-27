$script.ready ['kartograph', 'qtip'], () ->
  $ ->
    c = $('#map')
    c.height(c.width() * 0.5)

    map = $K.map("#map")
    map.loadMap 'data/map-usa.svg', () ->
      map.loadCSS 'css/map_style.css', () ->
        map.addLayer('graticule')
        map.addLayer('graticule_1')
        map.addLayer('usa')


