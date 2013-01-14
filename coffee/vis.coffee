
# ---
# These global variables will be available 
# to all the transition functions 
# ---
paddingBottom = 20
width = 880
height = 600 - paddingBottom
duration = 750

# the domain of our scales will be set
# once we have loaded the data
x = d3.time.scale()
  .range([0, width])

y = d3.scale.linear()
  .range([height, 0])

color = d3.scale.category10()

# area generator to create the
# polygons that make up the
# charts
area = d3.svg.area()
    .interpolate("basis")
    .x((d) -> x(d.date))

# line generator to be used
# for the Area Chart edges
line = d3.svg.line()
    .interpolate("basis")
    .x((d) -> x(d.date))

# stack layout for streamgraph
# and stacked area chart
stack = d3.layout.stack()
  .values((d) -> d.values)
  .x((d) -> d.date)
  .y((d) -> d.count)
  .out((d,y0,y) -> d.count0 = y0)
  .order("reverse")

# axis to simplify the construction of
# the day lines
xAxis = d3.svg.axis()
  .scale(x)
  .tickSize(-height)
  .tickFormat(d3.time.format('%a %d'))

# we will populate this variable with our
# data array, once its been loaded
data = null

# Create the blank SVG the visualization will live in.
svg = d3.select("#vis").append("svg")
  .attr("width", width)
  .attr("height", height + paddingBottom)

# ---
# Called when the chart buttons are clicked.
# Hands off the transitioning to a new chart
# to separate functions, based on which button
# was clicked. 
# ---
transitionTo = (name) ->
  if name == "stream"
    streamgraph()
  if name == "stack"
    stackedAreas()
  if name == "area"
    areas()

# ---
# This is our initial setup function.
# Here we setup our scales and create the
# elements that will hold our chart elements.
# ---
start = () ->
  # first, lets setup our x scale domain
  # this assumes that the dates in our data are in order
  minDate = d3.min(data, (d) -> d.values[0].date)
  maxDate = d3.max(data, (d) -> d.values[d.values.length - 1].date)
  x.domain([minDate, maxDate])

  # D3's axis functionality usually works great
  # however, I was having some aesthetic issues
  # with the tick placement
  # here I extract out every other day - and 
  # manually specify these values as the tick 
  # values
  dates = data[0].values.map((v) -> v.date)
  index = 0
  dates = dates.filter (d) ->
    index += 1
    (index % 2) == 0

  xAxis.tickValues(dates)

  # the axis lines will go behind
  # the rest of the display, so create
  # it first
  svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + height + ")")
    .call(xAxis)

  # I want the streamgraph to emanate from the
  # middle of the chart. 
  # we can set the area's y0 and y1 values to 
  # constants to achieve this effect.
  area.y0(height / 2)
    .y1(height / 2)

  # now we bind our data to create
  # a new group for each request type
  g = svg.selectAll(".request")
    .data(data)
    .enter()

  requests = g.append("g")
    .attr("class", "request")

  # add some paths that will
  # be used to display the lines and
  # areas that make up the charts
  requests.append("path")
    .attr("class", "area")
    .style("fill", (d) -> color(d.key))
    .attr("d", (d) -> area(d.values))

  requests.append("path")
    .attr("class", "line")
    .style("stroke-opacity", 1e-6)

  # create the legend on the side of the page
  createLegend()

  # default to streamgraph display
  streamgraph()

# ---
# Code to transition to streamgraph.
#
# For each of these chart transition functions, 
# we first reset any shared scales and layouts,
# then recompute any variables that might get
# modified in other charts. Finally, we create
# the transition that switches the visualization
# to the new display.
# ---
streamgraph = () ->
  # 'wiggle' is the offset to use 
  # for streamgraphs.
  stack.offset("wiggle")

  # the stack layout will set the count0 attribute
  # of our data
  stack(data)

  # reset our y domain and range so that it 
  # accommodates the highest value + offset
  y.domain([0, d3.max(data[0].values.map((d) -> d.count0 + d.count))])
    .range([height, 0])

  # the line will be placed along the 
  # baseline of the streams, but will
  # be faded away by the transition below.
  # this positioning is just for smooth transitioning
  # from the area chart
  line.y((d) -> y(d.count0))

  # setup the area generator to utilize
  # the count0 values created from the stack
  # layout
  area.y0((d) -> y(d.count0))
    .y1((d) -> y(d.count0 + d.count))

  # here we create the transition
  # and modify the area and line for
  # each request group through postselection
  t = svg.selectAll(".request")
    .transition()
    .duration(duration)
 
  # D3 will take care of the details of transitioning
  # between the current state of the elements and
  # this new line path and opacity.
  t.select("path.area")
    .style("fill-opacity", 1.0)
    .attr("d", (d) -> area(d.values))

  # 1e-6 is the smallest number in JS that
  # won't get converted to scientific notation. 
  # as scientific notation is not supported by CSS,
  # we need to use this as the low value so that the 
  # line doesn't reappear due to an invalid number.
  t.select("path.line")
    .style("stroke-opacity", 1e-6)
    .attr("d", (d) -> line(d.values))

# ---
# Code to transition to Stacked Area chart.
#
# Again, like in the streamgraph function,
# we use the stack layout to manage
# the layout details.
# ---
stackedAreas = () ->
  # the offset is the only thing we need to 
  # change on our stack layout to have a completely
  # different type of chart!
  stack.offset("zero")
  # re-run the layout on the data to modify the count0
  # values
  stack(data)

  # the rest of this is the same as the streamgraph - but
  # because the count0 values are now set for stacking, 
  # we will get a Stacked Area chart.
  y.domain([0, d3.max(data[0].values.map((d) -> d.count0 + d.count))])
    .range([height, 0])

  line.y((d) -> y(d.count0))

  area.y0((d) -> y(d.count0))
    .y1((d) -> y(d.count0 + d.count))

  t = svg.selectAll(".request")
    .transition()
    .duration(duration)

  t.select("path.area")
    .style("fill-opacity", 1.0)
    .attr("d", (d) -> area(d.values))

  t.select("path.line")
    .style("stroke-opacity", 1e-6)
    .attr("d", (d) -> line(d.values))

# ---
# Code to transition to Area chart.
# ---
areas = () ->
  g = svg.selectAll(".request")

  # set the starting position of the border
  # line to be on the top part of the areas.
  # then it is immediately hidden so that it
  # can fade in during the transition below
  line.y((d) -> y(d.count0 + d.count))
  g.select("path.line")
    .attr("d", (d) -> line(d.values))
    .style("stroke-opacity", 1e-6)

 
  # as there is no stacking in this chart, the maximum
  # value of the input domain is simply the maximum count value,
  # which we precomputed in the display function 
  y.domain([0, d3.max(data.map((d) -> d.maxCount))])
    .range([height, 0])

  # the baseline of this chart will always
  # be at the bottom of the display, so we
  # can set y0 to a constant.
  area.y0(height)
    .y1((d) -> y(d.count))

  line.y((d) -> y(d.count))

  t = g.transition()
    .duration(duration)

  # transition the areas to be 
  # partially transparent so that the
  # overlap is better understood.
  t.select("path.area")
    .style("fill-opacity", 0.5)
    .attr("d", (d) -> area(d.values))

  # here we finally show the line 
  # that serves as a nice border at the
  # top of our areas
  t.select("path.line")
    .style("stroke-opacity", 1)
    .attr("d", (d) -> line(d.values))

# ---
# Called on legend mouse over. Shows the legend
# ---
showLegend = (d,i) ->
  d3.select("#legend svg g.panel")
    .transition()
    .duration(500)
    .attr("transform", "translate(0,0)")

# ---
# Called on legend mouse out. Hides the legend
# ---
hideLegend = (d,i) ->
  d3.select("#legend svg g.panel")
    .transition()
    .duration(500)
    .attr("transform", "translate(165,0)")

# ---
# Helper function that creates the 
# legend sidebar.
# ---
createLegend = () ->
  legendWidth = 200
  legendHeight = 245
  legend = d3.select("#legend").append("svg")
    .attr("width", legendWidth)
    .attr("height", legendHeight)

  legendG = legend.append("g")
    .attr("transform", "translate(165,0)")
    .attr("class", "panel")

  legendG.append("rect")
    .attr("width", legendWidth)
    .attr("height", legendHeight)
    .attr("rx", 4)
    .attr("ry", 4)
    .attr("fill-opacity", 0.5)
    .attr("fill", "white")

  legendG.on("mouseover", showLegend)
    .on("mouseout", hideLegend)

  keys = legendG.selectAll("g")
    .data(data)
    .enter().append("g")
    .attr("transform", (d,i) -> "translate(#{5},#{10 + 40 * (i + 0)})")

  keys.append("rect")
    .attr("width", 30)
    .attr("height", 30)
    .attr("rx", 4)
    .attr("ry", 4)
    .attr("fill", (d) -> color(d.key))

  keys.append("text")
    .text((d) -> d.key)
    .attr("text-anchor", "left")
    .attr("dx", "2.3em")
    .attr("dy", "1.3em")
  
# ---
# Function that is called when data is loaded
# Here we will clean up the raw data as necessary
# and then call start() to create the baseline 
# visualization framework.
# ---
display = (error, rawData) ->
  # a quick way to manually select which calls to display. 
  # feel free to pick other keys and explore the less frequent call types.
  filterer = {"Heating": 1, "Damaged tree": 1, "Noise": 1, "Traffic signal condition": 1, "General construction":1, "Street light condition":1}
  data = rawData.filter((d) -> filterer[d.key] == 1)

  # a parser to convert our date string into a JS time object.
  parseTime = d3.time.format.utc("%x").parse

  # go through each data entry and set its
  # date and count property
  data.forEach (s) ->
    s.values.forEach (d) ->
      d.date = parseTime(d.date)
      d.count = parseFloat(d.count)

    # precompute the largest count value for each request type
    s.maxCount = d3.max(s.values, (d) -> d.count)

  data.sort((a,b) -> b.maxCount - a.maxCount)

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
  d3.json("data/requests.json", display)

