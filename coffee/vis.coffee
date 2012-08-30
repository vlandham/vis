
root = exports ? this

Plot = () ->
  width = 1000
  height = 600
  data = []
  allData = []
  lines = null
  margin = {top: 20, right: 20, bottom: 20, left: 130}
  xScale = d3.scale.linear().range([0,width])
  yScale = d3.scale.linear().range([0,height])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)
  line = d3.svg.line()
    .x((d,i) -> xScale(i))
    .y((d) -> height - yScale(d.time))

  formatData = (rawData) ->
    rawData.forEach (d) ->
      d.run.forEach (r) ->
        name = r.name.split(" ")[0]
        points = name.split("-")
        r.points = ["P#{points[0]}", "P#{points[1]}"]
        r.path = r.points.join("-")
    rawData


  chart = (selection) ->
    selection.each (rawData) ->

      data = formatData(rawData)
      allData = data

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
    yScale.domain(yExtent)

    runData = lines.selectAll(".runs")
      .data(data, (d) -> d["Name"])

    runData.exit().transition().remove()


    runs = runData.enter()
      .append("g")
      .attr("class", "runs")

    runs.append("text")
      .attr("dy", 5)
      .attr("text-anchor", "end")
      .classed("hidden", true)
      .text((d) -> d["Name"])

    runData.selectAll("text")
      .attr("x", -8)
      .attr("y", (d) -> height - yScale(d.run[0].time))

    runs.append("path")
      .attr("stroke", "#e2e2e2")
      .attr("stroke-width", 1.7)
      .attr("fill", "none")
      .on("mouseover", showDetailsPath)
      .on("mouseout", hideDetailsPath)
    
    runData.selectAll("path").transition()
      .duration(2000)
      .attr("d", (d) -> line(d.run))

    runPoints = runData.selectAll(".run")
      .data((d) -> d.run)

    runPoints.exit().remove()

    run = runPoints.enter()

    circles = run.append("circle")
      .attr("cx", (d,i) -> xScale(i))
      .attr("cy", (d) -> height - yScale(d.time))
      .attr("r", 4)
      .attr("class", "run")
      .attr("fill", "steelblue")
      .on("mouseover", showDetailsPoint)
      .on("mouseout", hideDetailsPoint)

    runPoints.transition().duration(2000).attr("r",4)
      .attr("cx", (d,i) -> xScale(i))
      .attr("cy", (d) -> height - yScale(d.time))


 
  highlightMap = (d, highlighted) ->
    d3.select("#map ##{d.path}").classed("highlight", highlighted)
    d.points.forEach (p) -> d3.select("#map ##{p}").classed("highlight", highlighted)


  showDetailsPoint = (d,i) ->
    d3.select(this).classed("highlight", true)
    d3.select(this.parentNode).select("text").classed("hidden", false)
    d3.select(this.parentNode).select("path").classed("highlight", true)

    highlightMap(d, true)

  hideDetailsPoint = (d,i) ->
    d3.select(this).classed("highlight", false)
    d3.select(this.parentNode).select("text").classed("hidden", true)
    d3.select(this.parentNode).select("path").classed("highlight", false)
    highlightMap(d, false)


  showDetailsPath = (d,i) ->
    d3.select(this).classed("highlight", true)
    d3.select(this.parentNode).select("text").classed("hidden", false)


  hideDetailsPath = (d,i) ->
    d3.select(this).classed("highlight", false)
    d3.select(this.parentNode).select("text").classed("hidden", true)

  chart.updateData = (input) ->
    if !arguments.length
      data = allData
    else if input < 1
      number = Math.round(allData.length * input)
      data = allData[0..number]
    else
      number = input
      data = allData[0...number]
      console.log(data.length)
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
  display = (data) ->
    plotData("#vis", data, plot)

  showMap = (mapData) ->
    importedNode = document.importNode(mapData.documentElement, true)
    d3.select("#map").node().appendChild(importedNode)


  $("#10_percent").on "click", (d) ->
    plot.updateData(0.1)
    false

  $("#all").on "click", (d) ->
    plot.updateData()
    false

  $("#top_5").on "click", (d) ->
    plot.updateData(5)
    false


  d3.json("data/sprint_data.json", display)

  d3.xml("data/map.svg", "image/svg+xml", showMap)

