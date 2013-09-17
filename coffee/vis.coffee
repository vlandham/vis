
root = exports ? this

WorldPlot = () ->
  width = 960
  height = 500
  radius = 240
  origin = [-71, 42]
  rotate = [100,-45]
  velocity = [.013, 0.000]
  time = Date.now()
  data = []
  g = null
  points = null
  feature = null

  mworld = null

  projection = d3.geo.azimuthalEqualArea()
    # .scale(radius)
    .rotate([100, -45])
    .scale(1050)
    .translate([width / 2 - 40, height / 2 - 110])
    # .clipAngle(90 + 1e-6)
    # .precision(.1)

  path = d3.geo.path()
    .projection(projection)
    # .pointRadius(1.5)

  graticule = d3.geo.graticule()
    .extent([[-140, 20], [-60, 60]])
    .step([2, 2])

  click = (d) ->
    o1 = projection.invert(d3.mouse(this))
    lat = o1[0]
    lon = o1[1]


  redraw = () ->
    dt = Date.now() - time
    projection.rotate([rotate[0] + velocity[0] * dt, rotate[1] + velocity[1] * dt])
    feature.attr("d", path)
    points.selectAll(".symbol").attr("d", path)
    
    false

  addData = () ->
    i = Date.now()
    data.push({"type":"Feature", "id":i, "geometry":{"type":"Point", "coordinates":[getRandomInRange(-180, 180, 3), getRandomInRange(-180, 180, 3)]},"properties":{'time':Date.now()}})

    data = data.filter (d) ->
      tmin = Date.now() - d.properties.time
      tmin < 1200

    p = points.selectAll(".symbol")
      .data(data, (d) -> d.id)

    p.enter().append("path")
      .attr("class", "symbol")
      .attr("d", path.pointRadius((d,i) -> 3))

    temps = p.enter().append("circle")
      .attr("class", "temp_symbol")
      .attr("cx", (d,i) -> projection([d.geometry.coordinates[0], d.geometry.coordinates[1]])[0])
      .attr("cy", (d,i) -> projection([d.geometry.coordinates[0], d.geometry.coordinates[1]])[1])
      .attr("r", 0)

    temps.transition()
      .duration(200)
      .attr("r", 30)
      .attr("cx", (d,i) -> projection([d.geometry.coordinates[0], d.geometry.coordinates[1]])[0])
      .attr("cy", (d,i) -> projection([d.geometry.coordinates[0], d.geometry.coordinates[1]])[1])
      .remove()
      

    p.exit().remove()

    false

  chart = (selection) ->
    selection.each (rawData) ->

      # rawData = rawData.filter((d) -> d.country ).filter (d) -> +d.count > 5

      # data = rawData

      # console.log(data)

      # count_extent = d3.extent(data, (d) -> +d.count)
      # radius.domain(count_extent)
      # console.log(count_extent)

      svg = d3.select(this).selectAll("svg").data([[1,2,3]])
      svg.enter().append("svg")

      svg
        .attr("width", width)
        .attr("height", height)

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



      g.append("path")
        .datum(topojson.feature(mworld, mworld.objects.land))
        .attr("class", "land")
        .attr("d", path)

      g.append("path")
        .datum(graticule)
        .attr("class", "graticule")
        .attr("d", path)
      # g.insert("path", ".graticule")
      #   .datum(topojson.mesh(mworld, mworld.objects.countries, (a, b) -> a != b))
      #   .attr("class", "boundary")
      #   .attr("d", path)

      feature = svg.selectAll("path")

      # d3.timer(redraw)

      d3.timer(addData, 200)

      
      # g = svg.select("g")

      points = g.append("g").attr("id", "vis_points")


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


  chart.world = (_) ->
    if !arguments.length
      return mworld
    mworld = _
    chart

  return chart

# root.WorldPlot = WorldPlot

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)

$ ->

  worldplot = WorldPlot()

  display = (error, world, top_tweets) ->
    console.log(error)

    worldplot.world(world)
    plotData("#vis", [1,2,3], worldplot)


  queue()
    .defer(d3.json, "data/us.json")
    .await(display)

