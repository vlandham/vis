$script.ready ['kartograph', 'qtip'], () ->
  $ ->
    agg_values = ["percent_govt_leased", "rent_prsf", "total_leased_rsf", "total_annual_rent"]
    
    c = $('#map')
    c.height(c.width() * 0.5)

    symbols = []

    map = $K.map("#map")
    map.loadMap 'data/map-usa.svg', () ->
      console.log("map loaded")
      map.loadCSS 'css/map_style.css', () ->
        map.addLayer('graticule')
        map.addLayer('graticule_1')
        map.addLayer('usa')
      $.getJSON "data/properties.json", (data) ->
      # $.getJSON "data/properties_all.json", (data) ->
        console.log("data loaded")
        $.each data, (i,city) ->
          $.each agg_values, (j,value) ->
            key = value + "_avg"

        updateMap = () ->
          key = "total_annual_rent_avg"

          scale = $K.scale.linear(data, key)
          max = 1000

          $.each data, (i, city) ->
            points = [city.lon_lat, [city.lon_lat[0], city.lon_lat[1], scale(city[key])*max]]
            if symbols[i]
              bar = symbols[i]
              if Raphael.svg
                bar.animate({path: map.getGeoPathStr(points)},500)
              else
                bar.attr('path', map.getGeoPathStr(points))
            else
              bar = map.addGeoPath([city.lon_lat,city.lon_lat])
              bar.attr({
                stroke: "#024"
                opacity: 0.6
                'stroke-width': 4
                fill: 'none'
                'stroke-linecap': 'square'
              })
              if Raphael.svg
                bar.animate({path: map.getGeoPathStr(points)},500)
                bar.node.setAttribute('title', city.city)
                setTimeout () ->
                  $(bar.node).qtip({
                    content: {
                      title: city.city
                      text: city.state
                    }
                    position: {
                      target: 'mouse'
                      viewport: $(window)
                      adjust: {x:7, y:7}
                    }
                  }, 800)
              else
                bar.attr('path', map.getGeoPathStr(points))
              symbols.push(bar)
        updateMap()








