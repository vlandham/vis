
root = exports ? this

Plot = () ->
  width = 600
  height = 600
  data = []
  points = null
  margin = {top: 20, right: 20, bottom: 20, left: 20}
  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([0,height])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)

  chart = (selection) ->
    selection.each (rawData) ->

      data = rawData

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      points = g.append("g").attr("id", "vis_points")
      update()

  update = () ->
    points.selectAll(".point")
      .data(data).enter()
      .append("circle")
      .attr("cx", (d) -> xScale(xValue(d)))
      .attr("cy", (d) -> yScale(yValue(d)))
      .attr("r", 4)
      .attr("fill", "steelblue")

  chart.height = (_) ->
    if !arguments.length
      return height
    height = _
    chart

  chart.width = (_) ->
    if !arguments.length
      return width
    width = _
    chart

  chart.margin = (_) ->
    if !arguments.length
      return margin
    margin = _
    chart

  chart.x = (_) ->
    if !arguments.length
      return xValue
    xValue = _
    chart

  chart.y = (_) ->
    if !arguments.length
      return yValue
    yValue = _
    chart

  return chart

root.Plot = Plot

PLAYGROUND_COLOR = "#FC462E"
PARK_COLOR = "#4D8035"

map = null
markerLayer = null
geocodeLayer = null

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)


createFeature = (location) ->
  feature = {
    'type': 'Feature',
    'geometry':{'type':'Point', 'coordinates': [location.lon, location.lat] },
    'properties': {}
  }
  feature

findNearbyParks = (feature) ->
  allFeatures = markerLayer.features()
  nearby = allFeatures.filter (f) ->


geocode = (query, m) ->
 query = encodeURIComponent(query + " Kansas City")
 $('form.geocode').addClass('loading')
 reqwest({
      url: 'http://open.mapquestapi.com/nominatim/v1/search?format=json&&limit=1&q=' + query,
      type: 'jsonp',
      jsonpCallback: 'json_callback',
      success: (r) ->
        geocodeLayer.features([])
        $('form.geocode').removeClass('loading')

        if (r.length == 0)
          $('#geocode-error').text('This address cannot be found.').fadeIn('fast')
        else
          r = r[0]
          $('#geocode-error').hide()
          map.setExtent([{lat :r.boundingbox[1], lon: r.boundingbox[2] },
            { lat: r.boundingbox[0], lon: r.boundingbox[3] }])
          feature = createFeature(r)
          geocodeLayer.add_feature(feature)
          map.ease.location({lat: feature.geometry.coordinates[1], lon: feature.geometry.coordinates[0]}).zoom(map.zoom()).optimal()

          findNearbyParks(feature)
        })


        


bindGeocoder = () ->
  $('[data-control="geocode"] form').submit (e) ->
    console.log('bind')
    e.preventDefault()
    geocode($('input[type=text]', this).val(), map)


isPark = (properties) ->
  properties['PLAYGROUND'].toLowerCase() == 'yes'

symbolFor = (props) ->

  symbol = {name: 'park', color: PARK_COLOR}
  if isPark(props)
    symbol.name = 'star'
    # symbol.color = '#5F9D41'
    symbol.color = PLAYGROUND_COLOR
  symbol


convertData = (data) ->
  # data = data.filter (d) ->
  #   d.properties['GOLF'].toLowerCase() == 'no'

  data.forEach (loc) ->
    symbol = symbolFor(loc.properties)
    loc.properties['marker-color'] = symbol.color
    loc.properties['marker-symbol'] = symbol.name
    loc.properties['title'] = loc.properties['PARKNAME']
  data

displayDetails = (properties) ->
  d3.select("#park-info").html('')
  info_div = d3.select("#park-info").selectAll("h2").data([properties]).enter()

  info_div.append("h2")
    .text((d) -> d.title)

  info_div.append("h3")
    .text((d) -> d['ADDRESS'])
    .attr("class", "park-address")

  list = ['PLAYGROUND','RESTROOM']

  list = info_div.append("div")
    .attr("id", "park-info-list")
  list.append("p")
    .text("Details:")
  list.append("ul")

  list.append("li")
    .text((d) -> "Playground: #{d['PLAYGROUND']}")

switchFilter = (filterId) ->
  $(".markerfilter").toggleClass("selected", false)
  $("##{filterId}").toggleClass("selected", true)

filterMarkers = (filterId) ->
  markerLayer.filter (feature) ->
    if filterId == 'all'
      return true
    else if filterId == 'playgrounds'
      return isPark(feature.properties)
    true

$ ->

  $(".markerfilter").click (e) ->
    clickedFilter = $(this).attr('id')
    switchFilter(clickedFilter)
    filterMarkers(clickedFilter)
    

  map = mapbox.map('map')
  map.addLayer(mapbox.layer().id('vlandham.map-wc8hmk8u'))
  map.centerzoom({lat: 39.044, lon: -94.583}, 12)
  map.ui.zoomer.add()
  map.ui.zoombox.add()

  geocodeLayer = mapbox.markers.layer()
  map.addLayer(geocodeLayer)

  view = (data) ->
    features = convertData(data.features)
    markerLayer = mapbox.markers.layer()
    markerLayer.factory (feature) ->
      elem = mapbox.markers.simplestyle_factory(feature)
      MM.addEvent elem, 'click', (e) ->
        displayDetails(feature.properties)
        # map.ease.location({lat: feature.geometry.coordinates[1],
        # lon: feature.geometry.coordinates[0]}).zoom(map.zoom()).optimal()
      elem

    markerLayer.features(features)
    interaction = mapbox.markers.interaction(markerLayer)
    map.addLayer(markerLayer)

  bindGeocoder()

  d3.json("data/kcmo_parks.geojson", view)
