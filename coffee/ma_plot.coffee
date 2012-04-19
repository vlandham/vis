
root = exports ? this

MaPlot = () ->
  width = 600
  height = 600
  margin = {top: 20, right: 20, bottom: 20, left: 40}
  xValue = (d) -> parseFloat(d.a)
  yValue = (d) -> parseFloat(d.m)
  pValue = (d) -> parseFloat(d.p)
  id = (d) -> d.index

  # defaults are overwritten below
  yCutOff = 0.4
  yCutOffDomain = [0,5.0]

  # set up parameters for drawing
  radius = 3
  opacity = 1.0

  # hash of color functions
  colors =
    high_low: (d) ->
      if yValue(d) > 1.0
        "#A21705"
      else if yValue(d) < -1.0
        "#87A205"
      else
        "#ccc"
    p_value: (d) ->
      pScale(pValue(d))
    none: (d) ->
      "#ccc"

  # which color function in colors hash
  # is currently being used
  currentColor = "high_low"

  # selector to use to create data table
  dataTableSelection = "#data-list"

  baseG = null
  points = null
  allData = []
  filteredData = []

  xScale = d3.scale.linear().range([0,width])
  yScale = d3.scale.linear().range([0,height])
  pScale = d3.scale.linear().range(["#BDD7E7", "#08519C"])

  xDomain = (data) -> d3.extent(data, xValue)
  yDomain = (data) -> d3.extent(data, yValue).reverse()
  pDomain = (data) -> d3.extent(data, pValue).reverse()

  xAxis = d3.svg.axis().scale(xScale).orient("bottom")
  yAxis = d3.svg.axis().scale(yScale).orient("left")

  # helper function to determine if a point is inside
  # a brush extent
  insideExtent = (extent, d) ->
    extent[0][0] <= xValue(d) && xValue(d) <= extent[1][0] &&
      extent[0][1] <= yValue(d) && yValue(d) <= extent[1][1]

  # given a selection of points, update
  # the colors for these points based on 
  # brush and current color selection
  updateColor = (point_set) ->
    e = brush.extent()
    point_set.attr "fill", (d) ->
      if insideExtent(e,d)
        "blue"
      else
        colors[currentColor](d)

  # ----
  # Brush callback functions
  # ----

  brushOn = (p) ->
    # console.log("move")
    eventTarget = d3.select(d3.event.target)
    e = brush.extent()
    all_points = points.selectAll("circle")

    selected_points = all_points
      .filter (d) ->
        insideExtent(e,d)

    updateColor(all_points)
    displaySelected(selected_points)

  # create brush
  brush = d3.svg.brush()
    .on("brush", brushOn)

  # function to guess at good starting
  # point for cutoff
  setCutOff = () ->
    extent = yDomain(allData)
    max = d3.max(extent.map((d) -> Math.abs(d)))
    yCutOff = max / 8.0
    yCutOffDomain = [0,max]

  # ----
  # MAIN
  # ----
  chart = (selection) ->
    selection.each (data) ->
      allData = data

      setCutOff()

      xScale.domain(xDomain(data))
      yScale.domain(yDomain(data))
      pScale.domain(pDomain(allData))

      brush.x(xScale).y(yScale)

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      baseG = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      baseG.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(#{0},#{height})")
        .call(xAxis)

      baseG.append("g")
        .attr("class", "y axis")
        .attr("transform", "translate(#{0},#{0})")
        .call(yAxis)

      points = baseG.append("g")
        .attr("class", "points")

      chart.update()

      baseG.append("g").attr("class", "brush").call(brush)
      setupSelectedTable(d3.keys(data[0]))

  # Update function called with 
  # dataset changes and needs to be redrawn
  chart.update = () ->
    filteredData = chart.filter(allData)

    newPoints = points.selectAll("circle")
      .data(filteredData, (d) -> id(d))

    newPoints.exit().remove()

    newPoints.enter().append("circle")
      .attr("class", "point")
      .attr("cx", (d) -> xScale(xValue(d)))
      .attr("cy", (d) -> yScale(yValue(d)))
      .attr("r", radius)
      .attr("fill-opacity", opacity)

    updateColor(newPoints)

  # Filter function to remove displayed points
  # based on cutoff values
  chart.filter = (data) ->
    fd = data.filter (d) ->
      (Math.abs(yValue(d)) > yCutOff)
    fd

  # Initialize details table
  setupSelectedTable = (keys) ->
    table = d3.select(dataTableSelection).append("table").attr("class", "table table-condensed table-striped")
    head = table.append("thead").append("tr")
    head.selectAll("th").data(keys).enter().append("th").text((d) -> d)
    table.append("tbody")

  # Display brushed over points
  displaySelected = (selected_points) ->
    # selected_points looks to be the svg elements that are selected
    # first we extract out the data
    selected_data = []
    selected_points.each (d) -> selected_data.push(d)
    selectionRow = d3.select(dataTableSelection).select("table tbody")
      .selectAll("tr").data(selected_data, (d) -> id(d))

    selectionRow.exit().remove()
    # hack to make this work quickly
    selectionRow.enter()
      .append("tr").html((d,i) -> "<td>" + d3.values(d).join("</td><td>") + "</td>")

  # ----
  # GETTER/SETTERs
  # ----
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

  chart.radius = (_) ->
    if !arguments.length
      return radius
    radius = _
    chart

  chart.color = (_) ->
    if !arguments.length
      return currentColor
    currentColor = _
    chart

  chart.all_colors = () ->
    d3.keys(colors)

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

  chart.p = (_) ->
    if !arguments.length
      return pValue
    pValue = _
    chart

  chart.cutoff = (_) ->
    if !arguments.length
      return yCutOff
    yCutOff = _
    chart

  chart.cutoff_domain = (_) ->
    if !arguments.length
      return yCutOffDomain
    yCutOffDomain = _
    chart

  chart.y_domain = (_) ->
    if !arguments.length
      return yDomain
    yDomain = _
    chart

  chart.id = (_) ->
    if !arguments.length
      return id
    id = _
    chart

  chart.data = (_) ->
    if !arguments.length
      return allData
    allData = _
    chart

  return chart

# To get function outside of coffeescript encapsulation
root.MaPlot = MaPlot
# Hack to hide wierd d3 code till i understand it more
root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)
