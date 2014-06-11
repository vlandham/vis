
root = exports ? this

Plot = () ->
  width = 960
  height = 500
  data = []
  points = null
  margin = {top: 20, right: 20, bottom: 20, left: 20}
  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([0,height])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)

  g = null

  zoomed = () ->
     g.style("stroke-width", 1.5 / d3.event.scale + "px")
     g.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")")
     update()
  zoom = d3.behavior.zoom()
    .translate([0, 0])
    .scale(1)
    .scaleExtent([1, 8])
    .on("zoom", zoomed)
  
  projection = d3.geo.albersUsa()
    .scale(1000)
    .translate([width / 2, height / 2])

  path = d3.geo.path()
    .projection(projection)
  
  us = null

  chart = (selection) ->
    selection.each (rawData) ->

      data = rawData
      
      svg = d3.select(this).append("svg")
      # gEnter = svg.enter().append("svg")
      
      svg.attr("width", width)
      svg.attr("height", height)
      svg.append("rect")
        .attr("class", "background")
        .attr("width", width)
        .attr("height", height)

      g = svg.append("g")
      svg.call(zoom)
        # .on("click", reset)
      
        # .attr("transform", "translate(#{margin.left},#{margin.top})")

      g.selectAll("path")
        .data(topojson.feature(us, us.objects.states).features)
        .enter().append("path")
        .attr("d", path)
        .attr("class", "feature")
        
      g.append("path")
        .datum(topojson.mesh(us, us.objects.states, (a, b) -> a != b))
        .attr("class", "mesh")
        .attr("d", path)

      points = svg.append("g")
      update()


  update = () ->
    console.log('update')
    pg = points.selectAll(".point")
      .data(data)
    pg.enter()
      .append("circle")
      .attr("class", "point")
      .attr('r', 3)
    pg.attr('cx', (d) -> projection([d.lon, d.lat])[0])
      .attr('cy', (d) -> projection([d.lon, d.lat])[1])

    # points.selectAll(".point")
    #   .data(data).enter()
    #   .append("circle")
    #   .attr("cx", (d) -> xScale(xValue(d)))
    #   .attr("cy", (d) -> yScale(yValue(d)))
    #   .attr("r", 4)
    #   .attr("fill", "steelblue")

  chart.us = (_) ->
    if !arguments.length
      return us
    us = _
    chart

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
  display = (error, data, us) ->
    plot.us(us)
    plotData("#vis", data, plot)

  queue()
    .defer(d3.tsv, "data/locations.tsv")
    .defer(d3.json, "data/us.json")
    .await(display)

