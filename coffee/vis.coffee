
root = exports ? this

width = 960
height = 620
map = null
graticule = null
points = null
start = [98.00, -35.50]

tooltip = Tooltip("vis-tooltip", 230)

show_tooltip = (d,i) ->
  content = '<p class="main">' + d.city + ", " + d.state + '</span></p>'
  content += '<hr class="tooltip-hr">'
  content += '<p class="main">' + d.state + '</span></p>'
  tooltip.showTooltip(content,d3.event)

hide_tooltip = (d,i) ->
  tooltip.hideTooltip()

bar_scale = d3.scale.linear()
  .range([-2, -120])

projection = d3.geo.satellite()
  .distance(1.3)
  .scale(1200)
  .rotate([start[0], start[1], 0])
  .center([0, 0])
  .tilt(25)
  .clipAngle(45)

path = d3.geo.path()
  .projection(projection)

graticule = d3.geo.graticule()
  .extent([[-142, 23], [-47 + 1e-6, 67 + 1e-6]])
  .step([5, 5])

zoomer = () ->
  projection.translate(d3.event.translate).scale(d3.event.scale)
  map.attr("d", path)
  graticule.attr("d", path)
  points.selectAll(".point").attr "d", (d,i) ->
    "M"+projection(d.lon_lat) + "l 0 " + bar_scale(d[key])

zoom = d3.behavior.zoom()
  .translate(projection.translate())
  .scale(projection.scale())
  .scaleExtent([930, Infinity])
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
      .on("mouseover", show_tooltip)
      .on("mouseout", hide_tooltip)

  display_map = (error, states) ->
    map = svg.append("path")
      .datum(states)
      .attr("class", "boundary")
      .attr("d", path)


    d3.json("/data/properties_all.json", display_bars)


  d3.json("data/us-states.json", display_map)

