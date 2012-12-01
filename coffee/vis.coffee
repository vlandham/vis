
root = exports ? this

Map = () ->
  width = 960
  height = 960
  data = []

  chart = (selection) ->
    selection.each (rawData) ->

      data = rawData

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width )
      svg.attr("height", height )


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


root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)


width = 960
height = 960
map = null
graticule = null
points = null
start = [100.00, -30.50]

bar_scale = d3.scale.linear()
  .range([-2, -100])

projection = d3.geo.satellite()
  .distance(1.3)
  .scale(1200)
  .rotate([start[0], start[1], 0])
  .center([0, 15])
  .tilt(25)
  .clipAngle(45)

path = d3.geo.path()
  .projection(projection)

zoomer = () ->
  projection.translate(d3.event.translate).scale(d3.event.scale)
  map.attr("d", path)
  graticule.attr("d", path)
  points.selectAll(".point").attr "d", (d,i) ->
    "M"+projection(d.lon_lat) + "l 0 " + bar_scale(d[key])

zoom = d3.behavior.zoom()
  .translate(projection.translate())
  .scale(projection.scale())
  .on("zoom", zoomer)

key = "total_annual_rent_avg"

$ ->
  svg = d3.select("#vis").append("svg")
    .attr("width", width)
    .attr("height", height)
    .call(zoom)

  svg.append("rect")
    .attr("class", "background")
    .attr("width", width)
    .attr("height", height)
    .attr("pointer-events", "all")

  graticule = svg.append("path")
    .datum(graticule)
    .attr("class", "graticule")
    .attr("d", path)

  display_bars = (error, data) ->
    bar_scale.domain(d3.extent(data, (d) -> d[key]))

    points = svg.append("g")
      .attr("class", "points")

    points.selectAll(".point")
      .data(data).enter()
      .append("path")
      .attr("class", "point")
      .attr("stroke", "#002244")
      .attr("stroke-width", 4)
      .attr("opacity", 0.6)
      .attr("d", (d,i) -> "M"+projection(d.lon_lat) + "l 0 " + bar_scale(d[key]) )

  display_map = (error, states) ->
    map = svg.append("path")
      .datum(states)
      .attr("class", "boundary")
      .attr("d", path)

    d3.json("/data/properties_all.json", display_bars)


  d3.json("data/us-states.json", display_map)

