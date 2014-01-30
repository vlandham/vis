
root = exports ? this

Plot = () ->
  width = 900
  height = 600
  topHeight = 300
  data = []
  locs = null
  map = null
  margin = {top: 20, right: 20, bottom: 20, left: 140}
  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  # yScale = d3.scale.linear().domain([0,10]).range([0,height])
  yScale = d3.scale.ordinal().rangeRoundBands([0,height], 0.1)
  mapScale = d3.scale.ordinal().rangeRoundBands([0,width], 0.1)

  color = d3.scale.category10()

  # parseTime = d3.time.format("%Y-%m-%d").parse
  iso = d3.time.format.utc("%Y-%m-%dT%H:%M:%S.%LZ").parse

  parseData = (raw) ->
    startTimestamp = "2014-01-29T02:02:32.000Z"
    startTime = iso(startTimestamp)
    raw.forEach (d) ->
      d.time = iso(d.timestamp)
      d.type = if d.rfid_tag_id.slice(0,4) == "ABBA" then "person" else "item"
    raw = raw.filter (d) -> d.type == "person" and d.time > startTime
    timeExtent = d3.extent(raw, (d) -> d.time)
    xScale.domain(timeExtent)
    nest = d3.nest()
      .key((d) -> d.location)
      .entries(raw)
    yScale.domain(nest.map((d,i) -> i))
    mapScale.domain(nest.map((d,i) -> i))
    console.log(yScale.domain())
    nest

  chart = (selection) ->
    selection.each (rawData) ->

      data = parseData(rawData)
      console.log(data)

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + topHeight + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      locs = g.append("g").attr("id", "vis_points")
        .attr("transform", "translate(0,#{topHeight})")

      map = g.append("g").attr("id", "vis_map")
      update()

  updateMap = () ->
    map.selectAll(".dot")

  update = () ->
    locations = locs.selectAll(".location")
      .data(data)

    locations.exit().remove()
    locsE = locations.enter()
      .append("g")
      .attr("transform", (d,i) -> "translate(0,#{yScale(i)})")
    locsE.append("text")
      .attr("text-anchor", "end")
      .attr("dx", -6)
      .attr("dy", 6)
      .attr("y", yScale.rangeBand() / 2)
      .attr("fill", (d) -> color(d.key))
      .text((d) -> d.key)

    checks = locsE.selectAll(".check")
      .data(((d) -> d.values),((d) -> d.time))

    checks.exit().remove()

    checksE = checks.enter()
      .append("g")
      .attr("class", "check")
      .attr("transform", (d) -> "translate(#{xScale(d.time)})")
      .append("rect")
      .attr("height", yScale.rangeBand())
      .attr("width", 4)
      .attr("fill", (d) -> color(d.location))
      .attr("fill-opacity", 0.4)
      .on("click", (d) -> console.log(d))
    

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

  plot = Plot()
  display = (error, data) ->
    plotData("#vis", data, plot)

  queue()
    .defer(d3.csv, "data/rfid.csv")
    .await(display)

