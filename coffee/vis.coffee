
root = exports ? this

Plot = () ->
  width = 600
  height = 600
  data = []
  points = null
  margin = {top: 10, right: 20, bottom: 20, left: 0}
  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([height,0])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)

  chart = (selection) ->
    selection.each (rawData) ->

      data = rawData

      x1Extent = d3.extent(data, (d) -> d.x1)
      x2Extent = d3.extent(data, (d) -> d.x2)
      xScale.domain([Math.min(x1Extent[0],x2Extent[0]), Math.max(x1Extent[1], x2Extent[1])])

      y1Extent = d3.extent(data, (d) -> d.y1)
      y2Extent = d3.extent(data, (d) -> d.y2)
      yScale.domain([Math.min(y1Extent[0],y2Extent[0]), Math.max(y1Extent[1], y2Extent[1])])


      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      points = g.append("g").attr("id", "vis_points")
      update()

  update = () ->
    points.selectAll(".line")
      .data(data).enter()
      .append("path")
      .attr("class", "line")
      .attr("stroke", "steelblue")
      .attr("stroke-width", 5)
      .attr("d", (d) -> "M#{xScale(d.x1)},#{yScale(d.y1)}L#{xScale(d.x2)},#{yScale(d.y2)}")

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

findPositions = (data, lengthAttribute = "length", turn = -Math.PI / 2.0) ->
  one = Complex(0,1)
  currentTurn = turn
  currentPos = Complex["0"]
  currentX = 0
  currentY = 0

  data.forEach (d) ->
    d[lengthAttribute] = +(d[lengthAttribute])
    d.facing = (Math.PI / 2.0) + currentTurn
    # console.log("#{d.facing}")
    currentTurn += turn
    mult = one.mult(Complex(d.facing,0))
    console.log(mult)
    imgExp = Complex.exp(mult)
    # console.log("#{imgExp.r} #{imgExp.i}")
    d.move = Complex(d[lengthAttribute],0).mult(imgExp)
    d.pos = currentPos
    currentPos = currentPos.add(d.move)
    d.x2 = Math.round(d.pos.r)
    d.y2 = Math.round(d.pos.i)
    d.x1 = currentX
    d.y1 = currentY
    currentX = d.x2
    currentY = d.y2
    # console.log("#{d.y1}, #{d.x1}, #{d.y2}, #{d.x2}")
      
  data



$ ->




  plot = Plot()
  display = (error, data) ->
    newData = findPositions(data, "lens")
    console.log(newData)

    plotData("#vis", newData, plot)

  queue()
    .defer(d3.csv, "data/two.csv")
    .await(display)

