
root = exports ? this

width = 940
height = 500
map = null
graticule = null
points = null
data = null
svg = null
key = null
start_pos = [98.00, -35.50]
start_scale = 1000

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

color_scale = d3.scale.linear()
  .range(["#DEA3A1", "#B1302D"])
  # .range(["#BDC9E1", "#045A8D"])

projection = d3.geo.satellite()
  .distance(1.3)
  .scale(start_scale)
  .rotate([start_pos[0], start_pos[1], 0])
  .center([0, 0])
  .tilt(25)
  .clipAngle(45)

starting_translate = projection.translate()

path = d3.geo.path()
  .projection(projection)

graticule = d3.geo.graticule()
  .extent([[-142, 23], [-47 + 1e-6, 67 + 1e-6]])
  .step([5, 5])

update_lines = () ->
  points.selectAll(".point").attr "d", (d,i) ->
    "M"+projection(d.lon_lat) + "l 0 " + bar_scale(d[size_key])

update_color = () ->
  color_scale.domain([0, d3.max(data, (d) -> d[color_key])])
  update_key()
  points.selectAll(".point")
    .attr "stroke", (d,i) -> color_scale(d[color_key])

update_size = () ->
  bar_scale.domain(d3.extent(data, (d) -> d[size_key]))
  points.selectAll(".point").transition()
    .duration(400)
    .attr "d", (d,i) ->
      "M"+projection(d.lon_lat) + "l 0 " + bar_scale(d[size_key])


update_map = () ->
  map.attr("d", path)
  graticule.attr("d", path)
  update_lines()

zoomer = () ->
  projection.translate(d3.event.translate).scale(d3.event.scale)
  update_map()

zoom = d3.behavior.zoom()
  .translate(projection.translate())
  .scale(projection.scale())
  .scaleExtent([930, 9120])
  .on("zoom", zoomer)

reset_projection = () ->
  projection
    .scale(start_scale)
    .rotate([start_pos[0], start_pos[1], 0])
    .translate(starting_translate)
  update_map()

size_key = "total_leased_rsf"
color_key = "percent_govt_leased"

toggle_map = (type, new_key) ->
  if type == 'size'
    size_key = new_key
    update_size()
  else
    color_key = new_key
    update_color()

update_key = () ->
  key_values = color_scale.domain()

  key.selectAll(".key_text").remove()
  key.selectAll(".key_text").data(key_values)
    .enter()
    .append("text")
    .attr("class", "key_text")
    .attr("x", (d,i) -> if i == 0 then 25 else (25 + 120))
    .attr("y", (d,i) -> height - 25)
    .attr("text-anchor", "middle")
    .text((d) -> if color_key == "percent_govt_leased" then "#{Math.round(d)}%" else Math.round(d))

create_key = () ->
  key = svg.append("g")
    .attr("id", "key")

  gradient = svg.append("defs")
    .append("linearGradient")
  gradient.attr("id", "color_gradient")
    .attr("x1", "0%")
    .attr("x2", "100%")
    .attr("y1", "0%")
    .attr("y2", "0%")
  gradient.append("stop")
    .attr("offset", "0%")
    .style("stop-color", (d) -> color_scale.range()[0])
    .style("stop-opacity", 1)
  gradient.append("stop")
    .attr("offset", "100%")
    .style("stop-color", (d) -> color_scale.range()[1])
    .style("stop-opacity", 1)

  key.append("rect")
    .attr("x", 25)
    .attr("y", height - 60)
    .attr("width", 120)
    .attr("height", 20)
    .attr("fill", "url(#color_gradient)")

  update_key()


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
    color_scale.domain([0,d3.max(data, (d) -> d[color_key])])

    create_key()

    points = svg.append("g")
      .attr("class", "points")

    points.selectAll(".point")
      .data(data).enter()
      .append("path")
      .attr("class", "point")
      .attr("stroke", (d) -> color_scale(d[color_key]))
      .attr("stroke-width", 4)
      .attr("opacity", 0.9)
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

  $(".btn-toggle").on "click", (event) ->
    event.preventDefault()
    target = $(event.target)
    parent = target.parent()
    $(".btn", parent).removeClass('btn-primary')
    target.addClass("btn-primary")

    type = target.data("type")
    new_key = target.data("val")
    toggle_map(type, new_key)

  $("#btn-recenter").on "click", (event) ->
    event.preventDefault()
    reset_projection()

