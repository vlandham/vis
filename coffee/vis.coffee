
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

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)

symbolFor = (props) ->

  symbol = {name: 'park', color: '#4D8035'}
  if props['PLAYGROUND'].toLowerCase() == 'yes'
    symbol.name = 'star'
    symbol.color = '#5F9D41'
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


$ ->

  map = mapbox.map('map')
  map.addLayer(mapbox.layer().id('vlandham.map-wc8hmk8u'))
  map.centerzoom({lat: 39.044, lon: -94.583}, 12)
  map.ui.zoomer.add()
  map.ui.zoombox.add()

  view = (data) ->
    features = convertData(data.features)
    markerLayer = mapbox.markers.layer()
    markerLayer.factory (feature) ->
      elem = mapbox.markers.simplestyle_factory(feature)
      MM.addEvent elem, 'click', (e) ->
        displayDetails(feature.properties)
        console.log(feature)
      elem

    markerLayer.features(features)
    interaction = mapbox.markers.interaction(markerLayer)
    map.addLayer(markerLayer)


  d3.json("data/kcmo_parks.geojson", view)
