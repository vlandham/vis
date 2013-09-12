
root = exports ? this

getCoords = (data) ->
  c = []
  data.forEach (d,i) ->
    # c.push([d.lon, d.lat])
    c.push({"type":"Feature", "id":i, "geometry":{"type":"Point", "coordinates":[d.lon,d.lat]},"properties":d})
  c

prettyName = (d) ->

  name = d.country
  if d.region and d.local
    name = "#{d.local}, #{d.region}"
  else if d.region
    name = d.region
  else if d.local
    name = d.local

  name


BubblePlot = () ->

  width = 200
  height = 200
  radius = d3.scale.sqrt()
    .domain([0, 1e6])
    .range([3, (width / 2) - 20])
  div = null

  chart = (selection) ->
    selection.each (rawData) ->

      rawData = rawData.filter((d,i) -> d.region and d.local).filter((d,i) -> i < 16)

      data = rawData
      count_extent = d3.extent(data, (d) -> +d.count)
      radius.domain(count_extent)

      div = d3.select(this).data([data])


      bubble = div.selectAll(".bubble")
        .data(data)
        .enter().append("div")
        .attr("class", "bubble")

      bubble.append("h2")
        .text((d) -> prettyName(d))

      svg = bubble.append("svg")
        .attr("width", width)
        .attr("height", height)
        .attr("position", "absolute")

      svg.append("circle")
        .attr("cx", width / 2)
        .attr("cy", height / 2)
        .attr("r", (d) -> radius(+d.count))
        .attr("class", "symbol")





  return chart

WorldPlot = () ->
  width = 940
  height = 600
  data = []
  svg = null
  g = null
  points = null

  margin = {top: 20, right: 20, bottom: 20, left: 20}
  mworld = null

  radius = d3.scale.sqrt()
    .domain([0, 1e6])
    .range([2, 18])

  projection = d3.geo.ginzburg8()
    .scale(170)
    .rotate([30,0])
    .translate([width / 2, height / 2])
    .precision(.1)

  # getRadius = (d,i) ->
  #   console.log(d)
  #   3

  path = d3.geo.path()
    .projection(projection)
    # .pointRadius(getRadius)

  graticule = d3.geo.graticule()

  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([0,height])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)

  reset = () ->
    g.transition().duration(750).attr("transform", "")


  click = (d) ->
    b = path.bounds(d)

    g.transition().duration(750).attr("transform",
      "translate(" + projection.translate() + ")"
      + "scale(" + .95 / Math.max((b[1][0] - b[0][0]) / width, (b[1][1] - b[0][1]) / height) + ")"
      + "translate(" + -(b[1][0] + b[0][0]) / 2 + "," + -(b[1][1] + b[0][1]) / 2 + ")")


  redraw = () ->
    console.log('redraw')
    g.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")")

  chart = (selection) ->
    selection.each (rawData) ->

      rawData = rawData.filter((d) -> d.country ).filter (d) -> +d.count > 5

      data = rawData

      count_extent = d3.extent(data, (d) -> +d.count)
      radius.domain(count_extent)
      console.log(count_extent)

      svg = d3.select(this).selectAll("svg").data([data])
      svg.enter().append("svg")

      svg
        .attr("width", width)
        .attr("height", height)
        # .call(d3.behavior.zoom())
        # .on("zoom", redraw)

      svg.append("defs").append("path")
        .datum({type: "Sphere"})
        .attr("id", "sphere")
        .attr("d", path)

      svg.append("use")
        .attr("class", "stroke")
        .attr("xlink:href", "#sphere")

      svg.append("use")
        .attr("class", "fill")
        .attr("xlink:href", "#sphere")

      g = svg.append("g")

      g.append("rect")
        .attr("class", "cover")
        .attr("width", width)
        .attr("height", height)
        # .call(d3.behavior.zoom())
        # .on("zoom", redraw)


      g.append("path")
        .datum(graticule)
        .attr("class", "graticule")
        .attr("d", path)

      g.insert("path", ".graticule")
        .datum(topojson.feature(mworld, mworld.objects.land))
        .attr("class", "land")
        .attr("d", path)

      g.insert("path", ".graticule")
        .datum(topojson.mesh(mworld, mworld.objects.countries, (a, b) -> a != b))
        .attr("class", "boundary")
        .attr("d", path)

      
      # svg.attr("width", width + margin.left + margin.right )
      # svg.attr("height", height + margin.top + margin.bottom )

      # g = svg.select("g")
      #   .attr("transform", "translate(#{margin.left},#{margin.top})")

      points = g.append("g").attr("id", "vis_points")
      update()


  update = () ->
    # points.append("path")
    #   .datum({type: "LineString", coordinates: [[-77.05, 38.91], [56.35, 39.91]]})
    #   .attr("class", "route")
    #   .attr("stroke-width", 20)
    #   .attr("d", path)


    # reverse to plot biggest last
    coords = getCoords(data).reverse()
    # points.append("path")
    #   .datum({type: "FeatureCollection", features:coords})
    #   .attr("class", "points")
    #   .attr("d", path.pointRadius((d,i) -> radius(data[i].count)))
    #
    points.selectAll(".hidden_symbol")
      .data(coords)
    .enter().append("path")
      .attr("class", "hidden_symbol")
      .attr("d", path.pointRadius((d,i) -> Math.max(radius(+d.properties.count), 10) ))

    points.selectAll(".symbol")
      .data(coords)
    .enter().append("path")
      .attr("class", "symbol")
      .attr("d", path.pointRadius((d,i) -> radius(+d.properties.count) ))

    $('svg .hidden_symbol, svg .symbol').tipsy({
      gravity:'w'
      html:true
      title: () ->
        d = this.__data__
        "<strong>#{prettyName(d.properties)}</strong> <i>#{d.properties.count} tweets</i>"
    })

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

  chart.world = (_) ->
    if !arguments.length
      return mworld
    mworld = _
    chart

  return chart

root.WorldPlot = WorldPlot

root.plotData = (selector, data, world, plot) ->
  plot.world(world)
  d3.select(selector)
    .datum(data)
    .call(plot)



$ ->

  plot = WorldPlot()
  bubbles = BubblePlot()
  display = (error, data, world) ->
    plotData("#vis", data, world, plot)

    d3.select("#bubbles")
      .datum(data)
      .call(bubbles)


  queue()
    # .defer(d3.csv, "data/all_with_users_position.csv")
    .defer(d3.csv, "data/mbfw_position_aggregate.csv")
    .defer(d3.json, "data/world-50m.json")
    .await(display)

