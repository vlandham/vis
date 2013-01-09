
width = 880
height = 700
duration = 750

x = d3.time.scale()
  .range([0, width - 60])

y = d3.scale.linear()
  .range([height, 0])

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

  stacks()

transitionTo = (name) ->
  if name == "steam"
    steamgraph()
  if name == "stack"
    stacks()
  if name == "area"
    overlapAreas()

stacks = () ->
  stack.offset("zero")
  stack(symbols)

  y.domain([0, d3.max(symbols[0].values.map((d) -> d.price + d.price0))])
    .range([height, 0])

  line.y((d) -> y(d.price0))

  area.y0((d) -> y(d.price0))
    .y1((d) -> y(d.price0 + d.price))

  t = svg.selectAll(".symbol")
    .transition()
    .duration(duration)

  t.select("path.area")
    .style("fill-opacity", 1.0)
    .attr("d", (d) -> area(d.values))

  t.select("path.line")
    .style("stroke-opacity", 1e-6)
    .attr("d", (d) -> line(d.values))


steamgraph = () ->
  stack.offset("wiggle")

  stack(symbols)

  y.domain([0, d3.max(symbols[0].values.map((d) -> d.price + d.price0))])
    .range([height, 0])

  line.y((d) -> y(d.price0))

  area.y0((d) -> y(d.price0))
    .y1((d) -> y(d.price0 + d.price))

  t = svg.selectAll(".symbol")
    .transition()
    .duration(duration)
  
  t.select("path.area")
    .style("fill-opacity", 1.0)
    .attr("d", (d) -> area(d.values))

  t.select("path.line")
      .style("stroke-opacity", 1e-6)
      .attr("d", (d) -> line(d.values))

overlapAreas = () ->
  g = svg.selectAll(".symbol")

  line.y((d) -> y(d.price0 + d.price))

  g.select("path.line")
      .attr("d", (d) -> line(d.values))
      .style("stroke-opacity", 1e-6)

  y.domain([0, d3.max(symbols.map((d) -> d.maxPrice))])
    .range([height, 0])

  area.y0(height)
    .y1((d) -> y(d.price))

  line.y((d) -> y(d.price))

  t = g.transition()
    .duration(duration)

  t.select("path.area")
    .style("fill-opacity", 0.5)
    .attr("d", (d) -> area(d.values))

  t.select("path.line")
    .style("stroke-opacity", 1)
    .attr("d", (d) -> line(d.values))

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

    x.domain([
      d3.min(symbols, (d) -> d.values[0].date),
      d3.max(symbols, (d) -> d.values[d.values.length - 1].date)
    ])

    g = svg.selectAll("g")
      .data(symbols)
      .enter()

    sym = g.append("g")
      .attr("class", "symbol")

    sym.append("path")
      .attr("class", "area")
      .style("fill", (d) -> color(d.key))

    sym.append("path")
      .attr("class", "line")
      .style("stroke-opacity", 1e-6)

    start()

  d3.selectAll(".switch").on "click", (d) ->
    d3.event.preventDefault()
    id = d3.select(this).attr("id")
    transitionTo(id)
  d3.csv("data/stocks.csv", display)

