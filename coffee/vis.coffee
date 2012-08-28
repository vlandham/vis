
root = exports ? this

Plot = () ->
  width = 1000
  height = 600
  data = []
  lines = null
  margin = {top: 20, right: 20, bottom: 20, left: 20}
  xScale = d3.scale.linear().range([0,width])
  yScale = d3.scale.linear().range([0,height])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)
  line = d3.svg.line()
    .x((d,i) -> xScale(i))
    .y((d) -> height - yScale(d.time))

  chart = (selection) ->
    selection.each (rawData) ->

      data = rawData

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      lines = g.append("g").attr("id", "vis_lines")
      update()

  update = () ->

    xScale.domain([0,data[0].run.length])
    yMin = d3.min(data, (d) -> d3.min(d.run.map (e) -> e.time))
    yMax = d3.max(data, (d) -> d3.max(d.run.map (e) -> e.time))
    yExtent = [yMin, yMax]
    console.log(yExtent)
    yScale.domain(yExtent)
    runs = lines.selectAll(".runs")
      .data(data).enter()
      .append("g")
      .attr("class", "runs")

    runs.selectAll("path")
      .data((d) -> [d.run]).enter()
      .append("path")
      .attr("d", line)
      .attr("stroke", "#e2e2e2")
      .attr("stroke-width", 1)
      .attr("fill", "none")
    

    run = runs.selectAll(".run")
      .data( (d) -> d.run).enter().append("g").attr("class","run")

    run.append("circle")
      .attr("cx", (d,i) -> xScale(i))
      .attr("cy", (d) -> height - yScale(d.time))
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

  plot = Plot()
  display = (data) ->
    plotData("#vis", data, plot)


  d3.json("data/sprint_data.json", display)

