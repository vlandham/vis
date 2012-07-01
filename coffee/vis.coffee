
root = exports ? this

width = 800
height = 600

data = null
vis = null

render_states = (json) ->
  projection = d3.geo.albersUsa()
    .scale(width)
    .translate([0, 0])

  path = d3.geo.path()
    .projection(projection)

  svg = d3.select("#vis").append("svg")
    .attr("width", width)
    .attr("height", height)

  svg.append("rect")
    .attr("class", "background")
    .attr("width", width)
    .attr("height", height)

  g = svg.append("g")
    .attr("transform", "translate(#{width / 2},#{height / 2})")
  states = g.append("g")
    .attr("id", "states")

  labels = g.append("g")
    .attr("id", "state-labels")

  states.selectAll("path")
    .data(json.features)
    .enter().append("path")
    .attr("d", path)

$ ->

  d3.json "data/us-states.json", render_states
