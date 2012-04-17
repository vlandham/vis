
root = exports ? this

MaPlot = () ->
  width = 600
  height = 600
  margin = {top: 20, right: 20, bottom: 20, left: 40}
  xValue = (d) -> parseFloat(d.a)
  yValue = (d) -> parseFloat(d.m)

  radius = 3
  color = (d) -> if yValue(d) > 0 then "#000" else "#ccc"

  selected_display_element = "#table_display"

  g = null
  points = null

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
    display_selected(selected_points)

  brushEnd = (p) ->
    if brush.empty()
      points.selectAll("circle").attr("fill", color)

  brush = d3.svg.brush()
    .on("brushstart", brushStart)
    .on("brush", brushOn)
    .on("brushend", brushEnd)

  chart = (selection) ->
    selection.each (data) ->

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

      points.selectAll("circle")
        .data(data)
      .enter().append("circle")
        .attr("class", "point")
        .attr("cx", (d) -> xScale(xValue(d)))
        .attr("cy", (d) -> yScale(yValue(d)))
        .attr("r", radius)
        .attr("fill", color)

      points.call(brush)

  display_selected = (selected_points) ->
    ss = []
    selected_points.each (d) -> ss.push(d)
    selection = d3.select(selected_display_element).selectAll("p").data(ss, (d) -> d.index)

    selection.exit().remove()

    selection.enter()
      .append("p").html((d,i) -> "#{i} - #{d.index}")

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


  return chart

root.MaPlot = MaPlot
