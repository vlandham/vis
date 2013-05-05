
root = exports ? this

width = 700
height = 700

grid_size = 20
grid_type = 'plain'

node = []

link = []
links = []

name_data = []

g = null


force = d3.layout.force()
  .size([width, height])
  .gravity(1)
  .charge(-300)
  .linkDistance((d) -> (1 - d.weight) * 100)
  .linkStrength((d) -> d.weight * 5)


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
        raw_cell = []
        switch grid_type
          when 'hex'
            raw_cell =  [ i * grid_size + (j % 2) * grid_size * 0.5, j * grid_size * .85]
          when 'plain'
            raw_cell = [i * grid_size, j * grid_size]
          when 'shift'
            raw_cell = [i * grid_size, 1.5 * (j * grid_size + (i % 2) * grid_size * .5)]

        cell = {gx:projection.invert(raw_cell)[0], gy:projection.invert(raw_cell)[1]}
        cell.x = raw_cell[0]
        cell.y = raw_cell[1]
        r.cells.push(cell)

    console.log('grid init')
  r.dist = (a,b) ->
    Math.pow(a.x - b.x, 2) + Math.pow(a.y - b.y, 2)

  r.reset = () ->
    r.cells.forEach (c) ->
      c.occupied = false


  r.occupy = (p) ->
    minDist = 1000000
    candidate = null

    r.cells.forEach (c) ->
      if !c.occupied
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
  g.reset()
  node.each(updateNode)

  node
    .attr("cx", (d) -> d.screenX)
    .attr("cy", (d) -> d.screenY)

  link
    .attr("x1", (d) -> d.source.screenX)
    .attr("y1", (d) -> d.source.screenY)
    .attr("x2", (d) -> d.target.screenX)
    .attr("y2", (d) -> d.target.screenY)

indexForId = (data,node_id) ->
  i = 0
  data.forEach (d) ->
    if node_id == d["LINE_ID"]
      return i
    i += 1


setupLinks = (data) ->
  nest = d3.nest()
    .key((d) -> d["Title"])
    .entries(data)

  links = []

  total = 1
  nest.forEach (e) ->

    for i in [1..(e.values.length - 1)]
      # link = {source:total - 1, target:total, weight:1}
      link = {source:e.values[i - 1]['StationName'], target:e.values[i]['StationName'], weight:1}
      links.push(link)
      total += 1


  named_nest = d3.nest()
    .key((d) -> d['StationName'])
    .entries(data)

  name_hash = {}

  named_nest.forEach (e) ->
    name_data.push(e.values[0])
    name_hash[e.key] = name_data[name_data.length - 1]

  links.forEach (l) ->
    l.source = name_hash[l.source]
    l.target = name_hash[l.target]
  links



draw_map = () ->


  force.nodes(name_data)
    .links(links)

  force.on("tick", tick)

  g = grid(width, height)
  g.init()

  force.start()

  gg = svg.append("g")
    .attr("id", "map")

  gg.selectAll(".cell")
    .data(g.cells)
    .enter().append("circle")
    .attr("class", "cell")
    .attr("r", 4)
    .attr("cx", (d) -> d.x)
    .attr("cy", (d) -> d.y)
    .attr("fill", "#ddd")

  link = gg.selectAll("line.link")
    .data(force.links())
    .enter().append('line')
    .attr('class', 'link')
    .style('stroke-width', 1.5)
    .style('stroke', (d) -> d.source['Color'])


  node = gg.selectAll("circle.stop")
    .data(force.nodes())
    .enter().append("circle")
    .attr("class", "stop")
    .attr("r", 5)
    .attr("cx", (d) -> d.x)
    .attr("cy", (d) -> d.y)
    .style("fill", (d) -> color(d["Line"]))
    .style("fill", (d) -> "#" + d["Color"])
    .on("click", (d) -> console.log(d))



setupData = (data) ->
  data = data.filter (d) -> d["Line"] != "Commuter Rail"
  data.forEach (d) ->
    d.x = projection([parseFloat(d.stop_lon), parseFloat(d.stop_lat)])[0]
    d.y = projection([parseFloat(d.stop_lon), parseFloat(d.stop_lat)])[1]

  data

display = (error, data) ->
  data = setupData(data)
  links = setupLinks(data)
  draw_map()

clear = () ->
  svg.select("#map").remove()

$ ->
  d3.tsv("data/boston-mbta-data.tsv", display)

  $("[name=GRID_TYPE]").click () ->
    grid_type = $(this).attr("value")
    clear()
    draw_map()
  

