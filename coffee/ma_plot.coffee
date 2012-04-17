
root = exports ? this

MaPlot = () ->
  width = 600
  height = 600
  margin = {top: 20, right: 20, bottom: 20, left: 40}
  xValue = (d) -> parseFloat(d.a)
  yValue = (d) -> parseFloat(d.m)

  radius = 3
  color = (d) -> if yValue(d) > 0 then "#000" else "#ccc"

  xScale = d3.scale.linear().range([0,width])
  yScale = d3.scale.linear().range([0,height])

  xDomain = (data) -> d3.extent(data, xValue)
  yDomain = (data) -> d3.extent(data, yValue).reverse()

  xAxis = d3.svg.axis().scale(xScale).orient("bottom")
  yAxis = d3.svg.axis().scale(yScale).orient("left")

  brush = d3.svg.brush()
    .on("brushstart", brushStart)
    .on("brush", brush)
    .on("brushend", brushEnd)

  chart = (selection) ->
    selection.each (data) ->
      console.log(data)

      xScale.domain(xDomain(data))
      yScale.domain(yDomain(data))

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

      pointsG = g.append("g")
        .attr("class", "points")

      pointsG.selectAll("circle")
        .data(data)
      .enter().append("circle")
        .attr("class", "point")
        .attr("cx", (d) -> xScale(xValue(d)))
        .attr("cy", (d) -> yScale(yValue(d)))
        .attr("r", radius)
        .attr("fill", color)


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

  brushStart = (p) ->
    console.log("b")

  brush = (p) ->
    console.log("b")

  brushEnd = (p) ->
    console.log("b")

  return chart

root.MaPlot = MaPlot
