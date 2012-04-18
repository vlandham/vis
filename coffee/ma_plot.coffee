
root = exports ? this

MaPlot = () ->
  width = 600
  height = 600
  margin = {top: 20, right: 20, bottom: 20, left: 40}
  xValue = (d) -> parseFloat(d.a)
  yValue = (d) -> parseFloat(d.m)
  id = (d) -> d.index

  yCutOff = 0.4

  radius = 3
  color = (d) ->
    if yValue(d) > 1.0
      "#A21705"
    else if yValue(d) < -1.0
      "#87A205"
    else
      "#ccc"

  dataTableSelection = "#data-list"

  g = null
  points = null
  allData = []
  filteredData = []

  xScale = d3.scale.linear().range([0,width])
  yScale = d3.scale.linear().range([0,height])

  xDomain = (data) -> d3.extent(data, xValue)
  yDomain = (data) -> d3.extent(data, yValue).reverse()

  xAxis = d3.svg.axis().scale(xScale).orient("bottom")
  yAxis = d3.svg.axis().scale(yScale).orient("left")

  brushStart = (p) ->
    # points.call(brush.clear())
    if brush.empty()
      points.call(brush.clear())
      points.selectAll("circle").attr("fill", color)

  brushOn = (p) ->
    e = brush.extent()
    all_points = points.selectAll("circle")
    selected_points = all_points
      .filter (d) ->
        if e[0][0] <= xValue(d) && xValue(d) <= e[1][0] && e[0][1] <= yValue(d) && yValue(d) <= e[1][1]
          return true
        else
          return false
      
    all_points.attr("fill", color)
    selected_points.attr("fill", "blue")
    displaySelected(selected_points)

  brushEnd = (p) ->
    if brush.empty()
      points.selectAll("circle").attr("fill", color)

  brush = d3.svg.brush()
    .on("brushstart", brushStart)
    .on("brush", brushOn)
    .on("brushend", brushEnd)

  chart = (selection) ->
    selection.each (data) ->
      allData = data

      xScale.domain(xDomain(data))
      yScale.domain(yDomain(data))
      brush.x(xScale).y(yScale)

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      g.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(#{0},#{height})")
        .call(xAxis)

      g.append("g")
        .attr("class", "y axis")
        .attr("transform", "translate(#{0},#{0})")
        .call(yAxis)

      points = g.append("g")
        .attr("class", "points")

      chart.update()

      points.call(brush)
      setupSelectedTable(d3.keys(data[0]))

  chart.update = () ->
    filteredData = allData.filter (d) -> Math.abs(yValue(d)) > yCutOff
    newPoints = points.selectAll("circle")
      .data(filteredData, (d) -> id(d))

    newPoints.exit().remove()

    newPoints.enter().append("circle")
      .attr("class", "point")
      .attr("cx", (d) -> xScale(xValue(d)))
      .attr("cy", (d) -> yScale(yValue(d)))
      .attr("r", radius)
      .attr("fill", color)

  setupSelectedTable = (keys) ->
    table = d3.select(dataTableSelection).append("table").attr("class", "table table-condensed table-striped")
    head = table.append("thead").append("tr")
    head.selectAll("th").data(keys).enter().append("th").text((d) -> d)
    table.append("tbody")

  displaySelected = (selected_points) ->
    # selected_points looks to be the svg elements that are selected
    # first we extract out the data
    selected_data = []
    selected_points.each (d) -> selected_data.push(d)
    selectionRow = d3.select(dataTableSelection).select("table tbody")
      .selectAll("tr").data(selected_data, (d) -> id(d))

    selectionRow.exit().remove()

    selectionRow.enter()
      .append("tr").html((d,i) -> "<td>" + d3.values(d).join("</td><td>") + "</td>")

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
      return color
    color = _
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

  chart.cutoff = (_) ->
    if !arguments.length
      return yCutOff
    yCutOff = _
    chart

  chart.id = (_) ->
    if !arguments.length
      return id
    id = _
    chart

  return chart

root.MaPlot = MaPlot
