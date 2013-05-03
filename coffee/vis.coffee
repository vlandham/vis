
root = exports ? this

width = 700
height = 700

grid_size = 30
grid_type = 'hex'

node = []

link = []

g = null


force = d3.layout.force()
  .size([width, height])
  .gravity(1)
  .charge(-300)



color = d3.scale.category20()

svg = d3.select("#vis")
  .append("svg")
  .attr("width", width)
  .attr("height", height)

projection = d3.geo.mercator()
  .center([-71.0609, 42.3681])
  .translate([width / 2, height / 2])
  .scale([34000])

path = d3.geo.path()
  .projection(projection)

grid = (width, height) ->
  r = {}
  r.cells = []

  r.init = () ->
    for i in [0..(width / grid_size)]
      for j in [0..(height / grid_size)]
        cell = {}
        switch grid_type
          when 'hex'
            raw_cell =  [ i * grid_size + (j % 2) * grid_size * 0.5, j * grid_size * .85]
            cell = {gx:projection.invert(raw_cell)[0], gy:projection.invert(raw_cell)[1]}
            cell.x = raw_cell[0]
            cell.y = raw_cell[1]
            r.cells.push(cell)
    console.log('init')
  r.dist = (a,b) ->
    Math.pow(a.x - b.x, 2) + Math.pow(a.y - b.y, 2)

  r.occupy = (p) ->
    minDist = 1000000
    candidate = null

    r.cells.forEach (c) ->
      if true or !c.occupied
        d = r.dist(p, c)
        if d < minDist
          minDist = d
          candidate = c
    if candidate
      candidate.occupied = true
    candidate


  r


updateNode = (d) ->
  gridpoint = g.occupy(d)

  if gridpoint
    d.screenX = d.screenX || gridpoint.x
    d.screenY = d.screenY || gridpoint.y
    d.screenX += (gridpoint.x - d.screenX) * .2
    d.screenY += (gridpoint.y - d.screenY) * .2

    d.x += (gridpoint.x - d.x) * .05
    d.y += (gridpoint.y - d.y) * .05
  else
    d.screenX = d.x
    d.screenY = d.y

tick = (e) ->
  node.each(updateNode)

  node
    .attr("cx", (d) -> d.screenX)
    .attr("cy", (d) -> d.screenY)

draw_map = (data) ->

  force.nodes(data)

  force.on("tick", tick)

  g = grid(width, height)
  g.init()

  svg.selectAll(".cell")
    .data(g.cells)
    .enter().append("circle")
    .attr("class", "cell")
    .attr("r", 4)
    .attr("cx", (d) -> d.x)
    .attr("cy", (d) -> d.y)
    .attr("fill", "#ddd")

  node = svg.selectAll("circle.stop")
    .data(force.nodes())
    .enter().append("circle")
    .attr("class", "stop")
    .attr("r", 5)
    .attr("cx", (d) -> d.x)
    .attr("cy", (d) -> d.y)
    .style("fill", (d) -> color(d["Line"]))

  force.start()

setupData = (data) ->
  data = data.filter (d) -> d["Line"] != "Commuter"
  data.forEach (d) ->
    d.x = projection([parseFloat(d.stop_lon), parseFloat(d.stop_lat)])[0]
    d.y = projection([parseFloat(d.stop_lon), parseFloat(d.stop_lat)])[1]

display = (error, data) ->
  setupData(data)
  draw_map(data)

$ ->
  d3.tsv("data/boston-mbta-data.tsv", display)

