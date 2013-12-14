
root = exports ? this

Plot = () ->
  keep = {"jim":1,"dan":1}
  width = 600
  height = 600
  allData = []
  points = null
  margin = {top: 20, right: 20, bottom: 20, left: 20}
  xScale = d3.scale.linear().domain([0,20]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([0,height])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)

  prepareData = (data) ->
    nestByName = d3.nest()
      .key((d) -> d.name)
      .entries(data)
    nestByName

  chart = (selection) ->
    selection.each (rawData) ->

      allData = prepareData(rawData)

      svg = d3.select(this).append("svg")
      gEnter = svg.append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      points = g.append("g").attr("id", "vis_points")
      update()

  filterData = (data) ->
    data = data.filter (d) -> keep[d.key] == 1
    console.log(data)
    data

  update = () ->
    data = filterData(allData)
    g = points.selectAll("g")
      .data(data, (d) -> d.key)

    gE = g.enter()
      .append("g")
      .attr("transform", (d,i) -> "translate(#{0},#{i * 20})")

    gE.append("text")
      .text((d) -> d.key)

    vG = g.append("g")
      .attr("transform", (d,i) -> "translate(#{10},#{0})")

    g.transition()
      .duration(500)
      .attr("transform", (d,i) -> "translate(#{0},#{i * 20})")

    g.exit().remove()
      .each((d) -> console.log(d.key))

    # vG = g.selectAll(".v")
    #   .data(((d) -> d.values), ((d) -> d.type))
    v = vG.selectAll(".v")
      .data(((d) -> d.values), ((d) -> d.type))

    v.enter().append("circle")
      .attr("cx", (d,i) -> xScale(d.value))
      .attr("cy", 3)
      .attr("r", 3)
    
    # g.exit().transition()
    #   .duration(500)
    #   .attr("opacity", 0.0)

  chart.switch = () ->
    keep['jim'] = if keep['jim'] == 0 then 1 else 0
    update()

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
    # plot.switch()

  queue()
    .defer(d3.csv, "data/test.csv")
    .await(display)
  d3.select("#switch").on "click", () ->
    plot.switch()




