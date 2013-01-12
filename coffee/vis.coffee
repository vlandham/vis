
# ---
# These global variables will be available 
# to all the transition functions 
# ---
width = 880
height = 600
duration = 750

# We need to leave a bit of room
# for the titles - so the x
# scale doesn't go the full width
# of the visualization
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

# Create the blank SVG the visualization will live in.
svg = d3.select("#vis").append("svg")
  .attr("width", width)
  .attr("height", height)

# ---
# Called when the chart buttons are clicked.
# Hands off the transitioning to a new chart
# to separate functions, based on which button
# was clicked. 
# ---
transitionTo = (name) ->
  if name == "steam"
    steamgraph()
  if name == "stack"
    stacks()
  if name == "area"
    areas()

# ---
# This is our initial setup function.
# Here we setup our scales and create the
# elements that will hold our chart elements.
# ---
start = () ->
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

  areas()

# ---
# Code to transition to Area chart.
#
# For each of these chart transition functions, 
# we first reset any shared scales and layouts,
# then recompute any variables that might get
# modified in other charts. Finally, we create
# the transition that switches the visualization
# to the new display.
# ---
areas = () ->
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

# ---
# Code to transition to Stacked Area chart.
# ---
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

# ---
# Code to transition to Steamgraph.
# ---
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

# ---
# Function that is called when data is loaded
# Here we will clean up the raw data as necessary
# and then call start() to create the baseline 
# visualization framework.
# ---
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

  start()

# Document is ready, lets go!
$ ->

  # code to trigger a transition when one of the chart
  # buttons is clicked
  d3.selectAll(".switch").on "click", (d) ->
    d3.event.preventDefault()
    id = d3.select(this).attr("id")
    transitionTo(id)

  # load the data and call 'display'
  d3.csv("data/stocks.csv", display)

