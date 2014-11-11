
root = exports ? this


Fake = () ->
  width = 900
  height = 900
  data = []
  extents = {}
  margin = {top: 20, right: 20, bottom: 20, left: 20}

  parseData = (rawData) ->
    rawData.forEach (d) ->
      d.date = new Date(d.time)
    extents.ratio = d3.extent(rawData, (d) -> Math.abs(d.ratio))
    extents.top = d3.extent(rawData, (d) -> d.scrollTop)
    extents.date = d3.extent(rawData, (d) -> d.date)

  chart = (selection) ->
    selection.each (rawData) ->

      data = parseData(rawData)
      console.log(extents)

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

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

  chart

Plot = () ->
  width = 600
  height = 600
  data = []
  points = null
  margin = {top: 20, right: 20, bottom: 20, left: 20}
  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([0,height])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)

  chart = (selection) ->
    selection.each (rawData) ->

      data = rawData

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      points = g.append("g").attr("id", "vis_points")
      update()

  update = () ->
    points.selectAll(".point")
      .data(data).enter()
      .append("circle")
      .attr("cx", (d) -> xScale(xValue(d)))
      .attr("cy", (d) -> yScale(yValue(d)))
      .attr("r", 4)
      .attr("fill", "steelblue")

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


lastScrollTop = 0
$(window).scroll (e) ->
  st = $(this).scrollTop()
  # console.log(e)
  # console.log(st)
  scrollDiff = (st - lastScrollTop)
  console.log(scrollDiff)
  lastScrollTop = st

$ ->

  plot = Fake()
  display = (error, data) ->
    plotData("#vis", data, plot)

  queue()
    .defer(d3.json, "data/scroll_data.json")
    .await(display)

