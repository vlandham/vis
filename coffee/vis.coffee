
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



$ ->

  apiKey = "088d3df822cb4b33b9d95e9cedf889a5"
  seattle = [47.60620950083183, -122.3320707975654]
  seattle = [47.66, -122.3320707975654]

  map = L.map('map').setView(seattle, 12)
  L.tileLayer('http://{s}.tile.cloudmade.com/' + apiKey + '/998/256/{z}/{x}/{y}.png', {
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://cloudmade.com">CloudMade</a>'
  }).addTo(map)

  svg = d3.select(map.getPanes().overlayPane).append("svg")
  g = svg.append("g").attr("class", "leaflet-zoom-hide")
  feature = null
  bounds = null
  path = null

  projectPoint = (x, y) ->
    point = map.latLngToLayerPoint(new L.LatLng(y, x))
    this.stream.point(point.x, point.y)

  reset = () ->
    topLeft = bounds[0]
    bottomRight = bounds[1]

    svg.attr("width", bottomRight[0] - topLeft[0])
      .attr("height", bottomRight[1] - topLeft[1])
      .style("left", topLeft[0] + "px")
      .style("top", topLeft[1] + "px")

    g.attr("transform", "translate(" + -topLeft[0] + "," + -topLeft[1] + ")")
    feature.attr("d", path)
    
  

  # plot = Plot()
  display = (error, collection) ->

    transform = d3.geo.transform({point: projectPoint})
    path = d3.geo.path().projection(transform)
    bounds = path.bounds(collection)

    feature = g.selectAll("path")
      .data(collection.features)
      .enter().append("path")

    feature.attr("d", path)

    map.on("viewreset", reset)
    reset()

    
  #   plotData("#map", data, plot)

  queue()
    .defer(d3.json, "data/hoods.json")
    .await(display)

