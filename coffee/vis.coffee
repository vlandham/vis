
root = exports ? this

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

width = 880
height = 700
x = d3.time.scale()
  .range([0, width - 60])

y = d3.scale.linear()
  .range([height / 4 - 20, 0])

axis = d3.svg.line()
  .interpolate("basis")
  .x((d) -> x(d.date))
  .y(height)

color = d3.scale.category10()

line = d3.svg.line()
    .interpolate("basis")
    .x((d) -> x(d.date))
    .y((d) -> y(d.price))

area = d3.svg.area()
    .interpolate("basis")
    .x((d) -> x(d.date))
    .y0(height / 4 - 20)
    .y1((d) -> y(d.price))

stack = d3.layout.stack()
  .values((d) -> d.values)
  .x((d) -> d.date)
  .y((d) -> d.price)
  .out((d,y0,y) -> d.price0 = y0)
  .order("reverse")

stocks = null
symbols = null

svg = d3.select("#vis").append("svg")
  .attr("width", width)
  .attr("height", height)

start = () ->
  g = svg.selectAll(".symbol")

  g.each (d) ->
    y.domain([0, d.maxPrice])

  stacks()

areas = () ->
  g = svg.selectAll(".symbol")
  axis.y(height / 4 - 21)

  g.select(".line")

stacks = () ->
  stack(symbols)

  y.domain([0, d3.max(symbols[0].values.map((d) -> d.price + d.price0))])
    .range([height, 0])

  line.y((d) -> y(d.price0))

  area.y0((d) -> y(d.price0))
    .y1((d) -> y(d.price0 + d.price))

  svg.selectAll("path.area")
    .attr("d", (d) -> area(d.values))

$ ->

  display = (error, data) ->
    parse = d3.time.format("%b %Y").parse
    filter = {AAPL: 1, AMZN: 1, MSFT: 1, IBM: 1}
    stocks = data.filter((d) -> d.symbol in d3.keys(filter))

    symbols = d3.nest()
      .key((d) -> d.symbol)
      .entries(stocks)

    symbols.forEach (s) ->
      s.values.forEach (d) ->
        d.date = parse(d.date)
        d.price = parseFloat(d.price)
      s.maxPrice = d3.max(s.values, (d) -> d.price)
      s.sumPrice = d3.sum(s.values, (d) -> d.price)

    symbols.sort((a,b) -> b.maxPrice - a.maxPrice)
    min_date = d3.min(symbols, (d) -> d.values[0].date)
    max_date = d3.max(symbols, (d) -> d.values[d.values.length - 1].date)

    g = svg.selectAll("g")
      .data(symbols)
      .enter()
    sym = g.append("g")
      .attr("class", "symbol")

    sym.append("path")
      .attr("class", "area")

    sym.append("path")
      .attr("class", "line")

    start()

  d3.csv("data/stocks.csv", display)

