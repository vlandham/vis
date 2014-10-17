
root = exports ? this

formatTime = (date) ->
  hours = date.getHours()
  if hours > 12
    hours = hours - 12
  mins = date.getMinutes()
  if mins < 10
    mins = "0#{mins}"
  "#{hours}:#{mins}"


CustSparks = () ->
  width = 1000
  lineHeight = 30
  lineMargin = 6
  height = 600
  data = []
  margin = {top: 50, right: 40, bottom: 20, left: 30}
  g = null

  xScaleAbs = d3.time.scale().range([0,width])

  xScaleDiff = d3.scale.linear().range([0,width])

  show = "rel"

  xScale = if show == "abs" then xScaleAbs else xScaleDiff

  xAxisDiff = d3.svg.axis()
    .scale(xScaleDiff)
    .orient("top")
    .tickFormat (d) ->
      dd = getDuration(d)
      "#{dd.hours} hrs #{dd.minutes} mins"

  xAxisAbs = d3.svg.axis()
    .scale(xScaleAbs)
    .orient("top")

  xAxis = if show == "abs" then xAxisAbs else xAxisDiff

  yScale = d3.scale.ordinal()
    .domain(["home","category","product","checkout"]).rangePoints([0,lineHeight])

  xValue = (d) -> if show == "abs" then d.datetime else d.time_diff
  yValue = (d) -> d.type

  line = d3.svg.line()
    .x((d) -> xScale(xValue(d)))
    .y((d) -> yScale(yValue(d)))
    .interpolate("step-after")
 
  color = d3.scale.category10()

  color = d3.scale.ordinal()
    .domain(["home","category","product","checkout"])
    .range(["#2ca02c", "#1f77b4", "#ff7f0e", "#d62728"])
  
  # "2014-10-01 13:55:56.0"
  format = d3.time.format("%Y-%m-%d %X.0")

  setupDataOld = (rawData) ->
    data = []
    d3.map(rawData).forEach (k,v) ->
      cust = {}
      cust['session_id'] = k
      v.forEach (e) ->
        e.datetime = format.parse(e.time)
      v.sort (a,b) -> d3.ascending(a.datetime, b.datetime)
      cust['start_time'] = v[0].datetime
      v.forEach (e,i) ->
        e.time_diff = e.datetime - cust.start_time


      cust['views'] = v
      cust['view_count'] = v.length
      data.push(cust)
    data = data.sort (a,b) -> d3.descending(a.view_count, b.view_count)
    timeMin = d3.min(data, (d) -> d3.min(d.views, (v) -> v.datetime))
    timeMax = d3.max(data, (d) -> d3.max(d.views, (v) -> v.datetime))
    maxDiff = d3.max(data, (d) -> d3.max(d.views, (v) -> v.time_diff))
    console.log(maxDiff)

    xScaleAbs.domain([timeMin, timeMax])
    xScaleDiff.domain([0, maxDiff])
    data

  setupData = (data) ->
    data.forEach (cust) ->
      cust['views'].forEach (e) ->
        e.datetime = format.parse(e.time)
      cust['views'].sort (a,b) -> d3.ascending(a.datetime, b.datetime)
      cust['start_time'] = cust.views[0].datetime
      cust.views.forEach (e,i) ->
        e.time_diff = e.datetime - cust.start_time


      cust['view_count'] = cust.views.length
    data = data.sort (a,b) -> d3.descending(a.view_count, b.view_count)
    timeMin = d3.min(data, (d) -> d3.min(d.views, (v) -> v.datetime))
    timeMax = d3.max(data, (d) -> d3.max(d.views, (v) -> v.datetime))
    maxDiff = d3.max(data, (d) -> d3.max(d.views, (v) -> v.time_diff))
    console.log(maxDiff)

    xScaleAbs.domain([timeMin, timeMax])
    xScaleDiff.domain([0, maxDiff])
    data
      

  chart = (selection) ->
    selection.each (rawData) ->
      
      data = setupData(rawData)
      data = data.slice(0,100)
      # console.log(data)

      height = (lineHeight + lineMargin) * data.length

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      xAxisG = g.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(#{0},#{-20})")

      xAxisG.call(xAxis)
        

      display()

  mouseover = () ->
    circle.attr("opacity", 1.0)
    d3.selectAll(".static_year").classed("hidden", true)
    mousemove.call(this)

  # ---
  # Here is where the bulk of the interaction code lives.
  # When mouse moves, we want to grab the current year
  # the mouse is over. Then we want to pull out that
  # year's count from each of the data element's values.
  # ---
  mousemove = () ->
    year = xScale.invert(d3.mouse(this)[0]).getFullYear()
    date = format.parse('' + year)
    
    # The index into values will be the same for all
    # of the plots, so we can compute it once and
    # use it for the rest of the scrollables
    index = 0
    circle.attr("cx", xScale(date))
      .attr "cy", (c) ->
        index = bisect(c.values, date, 0, c.values.length - 1)
        yScale(yValue(c.values[index]))

    caption.attr("x", xScale(date))
      .attr "y", (c) ->
        yScale(yValue(c.values[index]))
      .text (c) ->
        yValue(c.values[index])

    curYear.attr("x", xScale(date))
      .text(year)

  # ---
  # When viewer moves mouse out of plot, hide
  # circle and annotations while showing
  # the x axis labels
  # ---
  mouseout = () ->
    d3.selectAll(".static_year").classed("hidden", false)
    circle.attr("opacity", 0)
    caption.text("")
    curYear.text("")

  display = () ->
    row = g.selectAll(".row").data(data)
      .enter().append("g")
      .attr("class", "row")
      .attr("transform", (d,i) -> "translate(0, #{(lineHeight + lineMargin) * i})")

    # row.append("text")
    #   .text((d) -> d.session_id)

    disp = row.append("g")
      .attr("class", "disp")

    disp.append("path")
      .attr("class", "line")
      .attr("d", (c) -> line(c.views))
    disp.selectAll(".view")
      .data((c) -> c.views)
      .enter().append("circle")
      .attr("class", "view")
      .attr("cx", (d) -> xScale(xValue(d)))
      .attr("cy", (d) -> yScale(yValue(d)))
      .attr("r", 2)
      .attr("fill", (d) -> color(d.type))

    $('svg .view').tipsy({
      gravity:'s'
      html:true
      title: () ->
        d = this.__data__
        "<strong>#{d.type}</strong> <br/> #{d.id} <br/> #{formatTime(d.datetime)}"
    })
  

      

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


$ ->

  plot = CustSparks()
  display = (error, data) ->
    console.log(error)
    plotData("#vis", data, plot)

  queue()
    .defer(d3.json, "data/sessions.json")
    .await(display)

