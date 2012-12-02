
root = exports ? this

width = 940
height = 500
map = null
graticule = null
points = null
data = null
start = [98.00, -35.50]

tooltip = Tooltip("vis-tooltip", 230)

show_tooltip = (d,i) ->
  content = '<p class="main">' + d.city + ", " + d.state + '</p>'
  content += '<hr class="tooltip-hr">'
  content += '<span class="name">Leased SF: </span><span class="value">' + fixUp(d.total_leased_rsf) + '</span><br/>'
  content += '<span class="name">Total Rent: </span><span class="value">' + fixUp(d.total_annual_rent) + '</span><br/>'
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

update_lines = () ->
  points.selectAll(".point").attr "d", (d,i) ->
    "M"+projection(d.lon_lat) + "l 0 " + bar_scale(d[size_key])

update_size = () ->
  bar_scale.domain(d3.extent(data, (d) -> d[size_key]))
  points.selectAll(".point").transition()
    .duration(250)
    .attr "d", (d,i) ->
      "M"+projection(d.lon_lat) + "l 0 " + bar_scale(d[size_key])


zoomer = () ->
  projection.translate(d3.event.translate).scale(d3.event.scale)
  map.attr("d", path)
  graticule.attr("d", path)
  update_lines()

zoom = d3.behavior.zoom()
  .translate(projection.translate())
  .scale(projection.scale())
  .scaleExtent([930, Infinity])
  .on("zoom", zoomer)

size_key = "total_leased_rsf"

update_map = (type, new_key) ->
  if type == 'size'
    size_key = new_key
    update_size()

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

  display_bars = (error, bar_data) ->
    data = bar_data
    bar_scale.domain(d3.extent(data, (d) -> d[size_key]))

    points = svg.append("g")
      .attr("class", "points")

    points.selectAll(".point")
      .data(data).enter()
      .append("path")
      .attr("class", "point")
      .attr("stroke", "#002244")
      .attr("stroke-width", 4)
      .attr("opacity", 0.6)
      .on("mouseover", show_tooltip)
      .on("mouseout", hide_tooltip)
    update_lines()

  display_map = (error, states) ->
    map = svg.append("path")
      .datum(states)
      .attr("class", "boundary")
      .attr("d", path)


    d3.json("/data/properties_all.json", display_bars)


  d3.json("data/us-states.json", display_map)

  $(".btn").on "click", (event) ->
    event.preventDefault()
    target = $(event.target)
    parent = target.parent()
    $(".btn", parent).removeClass('btn-primary')
    target.addClass("btn-primary")

    type = target.data("type")
    new_key = target.data("val")
    update_map(type, new_key)

