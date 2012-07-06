
root = exports ? this

FeltMap = () ->
  width = 1024
  height = 600
  margin = {top: 20, right: 20, bottom: 20, left: 20}
  latValue = (d) -> parseFloat(d.lat)
  lonValue = (d) -> parseFloat(d.lon)
  data = []
  locations = []
  lines = []
  projection = d3.geo.mercator().scale(width).translate([width / 2, height / 2])
  path = d3.geo.path().projection(projection)
  mapG = null
  locG = null
  linesG = null
  node = null
  line = null
  map = null
  lineColor = "#fff"
  nodeColor = "#fff"
  lineSize = 1.3
  mapOpacity = 0.8
  nodeRadius = 0

  zoomer = () ->
    projection.translate(d3.event.translate).scale(d3.event.scale)
    map.attr("d", path)
    update()

  zoom = d3.behavior.zoom()
    .translate(projection.translate())
    .scale(projection.scale())
    .scaleExtent([height, 10 * height])
    .on("zoom", zoomer)

  fmap = (selection) ->
    selection.each (rawData) ->
      data = rawData
      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg")
      svg.attr("width", width + margin.left + margin.right )
        .attr("height", height + margin.top + margin.bottom )

      g = svg.append("g")
        .attr("id", "svg_vis")
        .attr("transform", "translate(#{margin.top},#{margin.left})")

      mapG = g.append("g")
        .attr("id", "countries")
        .call(zoom)

      mapG.append("rect")
        .attr("class", "background")
        .attr("width", width)
        .attr("height", height)
        .attr("pointer-events", "all")

      linesG = g.append("g")
        .attr("id", "lines")

      locG = g.append("g")
        .attr("id", "locations")

      d3.json "data/countries.geo.json", (json) ->
        drawMap(json)
        update()

  fmap.opacity = (_) ->
    if !arguments.length
      return mapOpacity
    mapOpacity = _
    map.style("opacity", mapOpacity)

  fmap.line = (_) ->
    if !arguments.length
      return lineColor
    lineColor = _
    line.style("stroke", lineColor)

  fmap.node = (_) ->
    if !arguments.length
      return nodeColor
    nodeColor = _
    node.style("fill", nodeColor)

  fmap.add = (point) ->
    data.push(point)
    update()

  fmap.remove = (index) ->
    console.log(index)
    # data.push(point)
    # update()

  drawMap = (json) ->
    map = mapG.selectAll("path")
      .data(json.features)
    map.enter()
      .append("path")
      # .on("click", click)
    
    map.attr("d", path)
      .style("opacity", mapOpacity)

  setupLocations = () ->
    locations = []
    data.forEach (loc) ->
      locations.push(projection([lonValue(loc), latValue(loc)]))
    locations

  setupLines = () ->
    lines = d3.geom.delaunay(locations)
    lines

  update = () ->
    setupLocations()
    setupLines()

    line = linesG.selectAll("path.link")
      .data(lines)

    line.enter()
      .append("path")
      .attr("class","link")
      .style("fill", "none")
      .style("stroke", lineColor)
      .style("stroke-width", lineSize)
    line.attr("d", (d) -> "M" + d.join("L") + "Z")

    line.exit().remove()

    node = locG.selectAll("circle.location")
      .data(locations)
    node.enter()
      .append("circle")
      .attr("class", "location")
    node.attr("cx", (d) -> d[0])
      .attr("cy", (d) -> d[1])
      .attr("r", nodeRadius)
      .style("fill", nodeColor)

  click = (d) ->
    centroid = path.centroid(d)
    translate = projection.translate()
    projection.translate([
      translate[0] - centroid[0] + width / 2,
      translate[1] - centroid[1] + height / 2
    ])

    zoom.translate(projection.translate())
    map.transition()
      .duration(1000)
      .attr("d", path)
  
    update()


  fmap.height = (_) ->
    if !arguments.length
      return height
    height = _
    chart

  fmap.width = (_) ->
    if !arguments.length
      return width
    width = _
    chart

  fmap.margin = (_) ->
    if !arguments.length
      return margin
    margin = _
    chart

  return fmap


plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)

$ ->
  map = FeltMap()
  d3.csv "data/locations.csv", (data) ->
    plotData("#vis", data, map)

  d3.select("#mapOpacity").on "change", (d) ->
    map.opacity(parseFloat(this.value))

  $('#pointSubmit').click (e) ->
    e.preventDefault()
    val = $('#pointInput').val()
    point = val.split(",").map (s) -> parseFloat(s)
    point = {"lat": point[0], "lon":point[1]}
    map.add(point)
    $('#pointInput').val("")


  $("#backgroundColor").miniColors({
    value: "#A4DCDD",
	  letterCase: 'uppercase',
	  change: (hex, rgb) ->
      $('body').css({"background-color":hex})
    })
  
  $("#lineColor").miniColors({
	  letterCase: 'uppercase',
		change: (hex, rgb) ->
      map.line(hex)
	  })

