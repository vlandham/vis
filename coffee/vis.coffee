
root = exports ? this

# Help with the placement of nodes
RadialPlacement = () ->
  # stores the key -> location values
  values = d3.map()
  # how much to separate each location by
  increment = 20
  # how large to make the layout
  radius = 200
  # where the center of the layout should be
  center = {"x":0, "y":0}
  # what angle to start at
  start = -120
  current = start

  # Given an center point, angle, and radius length,
  # return a radial position for that angle
  radialLocation = (center, angle, radius) ->
    x = (center.x + radius * Math.cos(angle * Math.PI / 180))
    y = (center.y + radius * Math.sin(angle * Math.PI / 180))
    {"x":x,"y":y}

  # Main entry point for RadialPlacement
  # Returns location for a particular key,
  # creating a new location if necessary.
  placement = (key) ->
    value = values.get(key)
    if !values.has(key)
      value = place(key)
    value

  # Gets a new location for input key
  place = (key) ->
    value = radialLocation(center, current, radius)
    values.set(key,value)
    current += increment
    value

   # Given a set of keys, perform some 
  # magic to create a two ringed radial layout.
  # Expects radius, increment, and center to be set.
  # If there are a small number of keys, just make
  # one circle.
  setKeys = (keys) ->
    # start with an empty values
    values = d3.map()
  
    # number of keys to go in first circle
    firstCircleCount = 360 / increment

    # if we don't have enough keys, modify increment
    # so that they all fit in one circle
    if keys.length < firstCircleCount
      increment = 360 / keys.length

    # set locations for inner circle
    firstCircleKeys = keys.slice(0,firstCircleCount)
    firstCircleKeys.forEach (k) -> place(k)

    # set locations for outer circle
    secondCircleKeys = keys.slice(firstCircleCount)

    # setup outer circle
    radius = radius + radius / 1.8
    increment = 360 / secondCircleKeys.length

    secondCircleKeys.forEach (k) -> place(k)

  placement.keys = (_) ->
    if !arguments.length
      return d3.keys(values)
    setKeys(_)
    placement

  placement.center = (_) ->
    if !arguments.length
      return center
    center = _
    placement

  placement.radius = (_) ->
    if !arguments.length
      return radius
    radius = _
    placement

  placement.start = (_) ->
    if !arguments.length
      return start
    start = _
    current = start
    placement

  placement.increment = (_) ->
    if !arguments.length
      return increment
    increment = _
    placement

  return placement


Plot = () ->
  width = 600
  height = 1200
  radius = 6.5
  data = []
  cells = null
  edges = null
  margin = {top: 20, right: 20, bottom: 20, left: 20}
  colorScale = d3.scale.ordinal().range(["#ff7f0e", "#1f77b4"]).domain([1,2])
  lineColor = "#aaa"
  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([0,height])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)

 
  arc = (source, target) ->
    dx = target.x - source.x
    dy = target.y - source.y
    dr = Math.sqrt(dx * dx + dy * dy)
    "M" + source.x + "," + source.y + "A" + dr + "," + dr + " 0 0,1 " + target.x + "," + target.y

  chart = (selection) ->
    selection.each (rawData) ->

      data = rawData

      svg = d3.select(this).selectAll("svg").data([data])
      svg = svg.enter().append("svg")

      # crappy place to put line arrow
      svg.append("defs").append("marker")
        .attr("id", "arrow")
        .attr("viewBox", "0 -5 10 10")
        .attr("refX", 15)
        .attr("refY", -1.5)
        .attr("markerWidth", 6)
        .attr("markerHeight", 6)
        .attr("orient", "auto")
        .attr("fill", lineColor)
        .append("path").attr("d", "M0,-5L10,0L0,5")

      gEnter = svg.append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      edges = g.append("g").attr("id", "edges")
      cells = g.append("g").attr("id", "cells")
      update()

  update = () ->
    [1,2].forEach (layer_index) ->
      placement = RadialPlacement().center({"x":width/2, "y":height / 4 + ( (height / 4 + 100) * (layer_index - 1))})
        .radius(150).increment(15)
      layer = cells.append("g").attr("id", "layer_#{layer_index}")
      layer_nodes = data.nodes.filter (d) -> d.layer == layer_index
      ids = layer_nodes.map (d) -> d.id
      placement.keys(ids)
      layer_nodes.forEach (d) ->
        d.location = placement(d.id)

      layer.selectAll(".cell")
        .data(layer_nodes).enter()
        .append("circle")
        .attr("class", "cell")
        .attr("cx", (d) -> d.location.x)
        .attr("cy", (d) -> d.location.y)
        .attr("r", radius)
        .attr("fill", (d) -> colorScale(d.layer))
    update_links()

  # Helper function to map node id's to node objects.
  # Returns d3.map of ids -> nodes
  mapNodes = (nodes) ->
    nodesMap = d3.map()
    nodes.forEach (n) ->
      nodesMap.set(n.id, n)
    nodesMap

  update_links = () ->
    line = d3.svg.line().interpolate("cardinal")
      .x((d) -> d.x)
      .y((d) -> d.y)

    links = data.links
    # add connectors between layers
    d3.select("#layer_1").selectAll(".cell").each (d) ->
      source = d.id
      target = "2#{source}"
      links.push {"source":source, "target":target, "type":"cross"}

    # id's -> node objects
    nodesMap  = mapNodes(data.nodes)

    # switch links to point to node objects instead of id's
    links.forEach (l) ->
      l.source = nodesMap.get(l.source)
      l.target = nodesMap.get(l.target)
      l.points = [l.source.location, l.target.location]


    edges.selectAll(".edge").data(links).enter()
      .append("path")
      .attr("class", "edge")
      .attr "d", (d) ->
        if d.type == "cross"
          line(d.points)
        else
          arc(d.points[0], d.points[1])
      # .attr("d", (d) -> line(d.points))
      # .attr("d", (d) -> arc(d.points[0], d.points[1]))
      .attr("fill", "none")
      .attr("stroke", lineColor)
      .attr("stroke-width", 1.5)
      .attr("marker-end", "url(#arrow)")



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

  plot = Plot()
  display = (data) ->
    plotData("#vis", data, plot)


  d3.json("data/cells.json", display)

