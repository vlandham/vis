
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
  tooltip = CustomTooltip("tooltip", 240)
  margin = {top: 50, right: 40, bottom: 20, left: 30}
  g = null


  xScaleAbs = d3.time.scale().range([0,width])

  xScaleDiff = d3.scale.linear().range([0,width])

  show = "rel"

  bisectDate = d3.bisector((d) -> d.datetime).left
  bisectDiff = d3.bisector((d) -> d.time_diff).left


  bisect = if show == "abs" then bisectDate else bisectDiff

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
 
  # color = d3.scale.category10()

  color = d3.scale.ordinal()
    .domain(["home","category","product","checkout"])
    .range(["#2ca02c", "#1f77b4", "#ff7f0e", "#d62728"])

  brushed = () ->
    a = 1

  brush = d3.svg.brush()
    .x(xScale)
    .on("brush", brushed)
  
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
    mousemove.call(this)

  # ---
  # Here is where the bulk of the interaction code lives.
  # When mouse moves, we want to grab the current year
  # the mouse is over. Then we want to pull out that
  # year's count from each of the data element's values.
  # ---
  mousemove = (d) ->
    x0 = xScale.invert(d3.mouse(this)[0])
    i = bisect(d.views, x0, 1, d.views.length - 1)
    d0 = d.views[i - 1]
    d1 = d.views[i]
    d = if (x0 - d0.time_diff) > (d1.time_diff - x0) then d1 else d0
    e = if (x0 - d0.time_diff) > (d1.time_diff - x0) then i else i - 1
    d3.select(this.parentNode).selectAll(".view")#.filter((d,x) -> x == i)
      .attr("r", (d,x) -> if x == e then 4 else 2)
    # $(this.parentNode).find(".view").filter((x) -> x == i)
    #   .tipsy("show")
    str = "<strong>#{d.type}</strong><br/>#{d.id}<br/>#{formatTime(d.datetime)}"
    tooltip.showTooltip(str,d3.event)

    

  # ---
  # When viewer moves mouse out of plot, hide
  # circle and annotations while showing
  # the x axis labels
  # ---
  mouseout = () ->
    tooltip.hideTooltip()
    d3.select(this.parentNode).selectAll(".view")
      .attr("r", 2)
    # d3.selectAll(".static_year").classed("hidden", false)
    # circle.attr("opacity", 0)
    # caption.text("")
    # curYear.text("")

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
      trigger: 'manual'
      title: () ->
        d = this.__data__
        "<strong>#{d.type}</strong> <br/> #{d.id} <br/> #{formatTime(d.datetime)}"
    })

    row.append("rect")
      .attr("width", width)
      .attr("height", lineHeight)
      .style("fill", "none")
      .style("pointer-events", "all")
      .on("mousemove", mousemove)
      .on("mouseout", mouseout)
  

      

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

