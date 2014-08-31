
root = exports ? this

Plot = () ->
  width = 800
  height = 400
  data = []
  points = null
  margin = {top: 20, right: 120, bottom: 70, left: 20}
  xScale = d3.time.scale().range([0,width])
  yScale = d3.scale.ordinal().rangeRoundBands([0,height], 0.1)
  xValue = (d) -> (d.date)
  yValue = (d) -> parseFloat(d.y)
  parseTime = d3.time.format("%m/%d/%Y").parse

  xAxis = d3.svg.axis()
    .scale(xScale)
    .tickSize(-height)
    # .tickFormat(d3.time.format('%b'))
    # .tickFormat(d3.time.format('%b %Y'))
  

  setupData = (rawData) ->
    rawData.forEach (d, i) ->
      d.index = i + 1
      d.events.forEach (e) ->
        e.date = parseTime(e.date)
    minDate = parseTime("06/01/1699")
    maxDate = parseTime("07/01/1722")
    xScale.domain([minDate, maxDate])
    yScale.domain(rawData.map((d) -> d.index))
    rawData

  mouseover = (d,i) ->
    console.log(d.title)
    person = d3.select(this.parentNode).datum()
    age = getAge(person.events[0].date, d.date)
    console.log("time since event[0]: " + age)
    last_index = if i == 0 then 0 else i - 1
    age = getAge(person.events[last_index].date, d.date)
    console.log("time since last event: " + age)

  chart = (selection) ->
    selection.each (rawData) ->

      console.log(rawData)
      data = setupData(rawData)

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      g.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + (height + 40) +  ")")
        .call(xAxis)

      points = g.append("g").attr("id", "vis_points")
      update()

  update = () ->

    persons = points.selectAll(".person")
      .data(data)

    personsE = persons.enter()
      .append('g')
      .attr("class", "person")
      .attr("transform", (d,i) -> "translate(0,#{yScale(d.index)})")

    personsE.append('line')
      .attr('x1', (d) -> xScale(xValue(d.events[0])))
      .attr('x2', (d) -> xScale(xValue(d.events[d.events.length - 1])))
      .attr('y1', yScale.rangeBand() / 2)
      .attr('y2', yScale.rangeBand() / 2)
      .attr("stroke", "#777")
      .attr("stroke-width", 1.5)
      .attr("stroke-opacity", 0.7)

    personsE.append('text')
      .attr("text-anchor", "start")
      .attr("dx", 10)
      .attr("dy", 6)
      .attr("y", yScale.rangeBand() / 2)
      .attr("x", width)
      # .attr("fill", "#000")
      .attr("font-size", 20)
      .text((d) -> d.name)
      
      

    events = personsE.selectAll(".event")
      .data(((d) -> d.events), ((d) -> d.title))

    eventsE = events.enter()

    eventsE.append("circle")
      .attr("class", "event")
      .attr("cx", (d) -> xScale(xValue(d)))
      .attr("cy", yScale.rangeBand() / 2 )
      .attr("r", 6)
      .attr("fill", "#777")
      .on("mouseover", mouseover)

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
    console.log(error)
    plotData("#vis", data, plot)

  queue()
    .defer(d3.json, "data/captain_z_timeline.json")
    .await(display)

