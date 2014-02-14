
$ ->

  base = new L.StamenTileLayer("watercolor")
  # map = new L.map("map1", {center: new L.LatLng(21.33258377832232, -157.90501690877136), zoom:10})

  hawaiiMap = new L.map("hawaiiMap", {center: new L.LatLng(21.571478713345897, -157.42299176228698), zoom:6, zoomControl:false})
  hawaiiMap.addLayer(base)

  base = new L.StamenTileLayer("watercolor")
  beachMap = new L.map("beachMap", {center: new L.LatLng(21.33258377832232, -157.90501690877136), zoom:11, zoomControl:false})
  beachMap.addLayer(base)

  fillColor = "#ff7800"
  geojsonMarkerOptions = {
    radius: 10,
    fillColor: fillColor,
    color: "#fff",
    weight: 3,
    opacity: 1,
    fillOpacity: 0.8
  }

  hoodStyle = {
    "color": "#fff",
    fillColor: fillColor,
    "weight": 3,
    "opacity": 0.9,
    fillOpacity: 0.8
  }
  

  beachToLayer = (feature, latlng) ->
    L.circleMarker(latlng, geojsonMarkerOptions)

  beachToText = (feature, latlng) ->
    console.log(latlng)
    latlng.lat += 0.0009
    latlng.lng += 0.004
    if feature.properties.name == 'Ala Moana'
      latlng.lat += 0.01
    if feature.properties.name == 'Sand Island'
      latlng.lng -= 0.09
    if feature.properties.name == 'Waikiki'
      latlng.lat -= 0.004
      # latlng.lng -= 0.01
    L.circleMarker(latlng, geojsonMarkerOptions)
    icon = L.divIcon({className:'label', html:feature.properties.name})
    L.marker(latlng, {icon: icon})

  bindBeach = (feature, layer) ->
    a = 1

  showBeaches = (err, json) ->
    L.geoJson(json, {pointToLayer:beachToLayer, onEachFeature:bindBeach}).addTo(beachMap)
    L.geoJson(json, {pointToLayer:beachToText, onEachFeature:bindBeach}).addTo(beachMap)

  showOahu = (err, json) ->
    L.geoJson(json, {style:hoodStyle}).addTo(hawaiiMap)

  showHawaii = (err, json) ->
    L.geoJson(json, {pointToLayer:beachToText}).addTo(hawaiiMap)

  d3.json('data/beaches.geojson', showBeaches)
  d3.json('data/oahu.geojson', showOahu)
  d3.json('data/hawaii.geojson', showHawaii)


