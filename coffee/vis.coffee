
root = exports ? this

createId = (d) ->
  name = d["Name"]
  name = name.toLowerCase().replace(/(\s+|'|")/g, "_")
  name

Plot = () ->
  width = 540
  height = 400
  data = []
  allData = []
  lines = null
  details = null
  yAxis = null
  margin = {top: 20, right: 50, bottom: 40, left: 15}
  xScale = d3.scale.linear().range([0,width])
  yScale = d3.scale.linear().range([height,0])
  line = d3.svg.line()
    .x((d,i) -> xScale(i))
    .y((d) ->  yScale(d.time))

  formatData = (rawData) ->
    rawData.forEach (d) ->
      d.id = createId(d)
      # console.log(d.id)
      d.run.forEach (r) ->
        name = r.name.split(" ")[0]
        points = name.split("-")
        r.points = ["P#{points[0]}", "P#{points[1]}"]
        r.path = r.points.join("-")
        r.control = r.name.split(" ")[1]
        r.name = name
        r.parent = d
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

      details = d3.select("#detail")

      yAxis = d3.svg.axis().scale(yScale).ticks(4).orient("right")

      lines = g.append("g").attr("id", "vis_lines")


      lines.append("g")
        .attr("class", "y axis")
        .attr("transform", "translate(#{width},0)")
        .call(yAxis)

      setupTable()

      updateX()
      update()

  updateX = () ->
    names = data[0].run.map (r) -> r.name
    xScale.domain([0,names.length])

    xAxis = lines.selectAll(".x_axis")
      .data([names])
      .enter().append("g")
      .attr("class", "x_axis")

    xNames = xAxis.selectAll(".anno")
      .data((d) -> d).enter()

    xNames.append("line")
      .attr("x1",(d,i) -> xScale(i))
      .attr("x2",(d,i) -> xScale(i))
      .attr("y1", height + 5)
      .attr("y2", height + 10)
      .attr("stroke", "black")

    xNames.append("text")
      .attr("class", "anno")
      .attr("text-anchor", "end")
      .attr("font-size", 11)
      .attr("transform", (d,i) -> "translate(#{xScale(i)+5},#{height + 16})rotate(-45)")
      .text((d) -> d)

  setupTable = () ->
    table = d3.select("#table").select("thead")

    header = table.selectAll("tr")
      .data([data[0].run])
      .enter().append("tr")

    header.append("th").text("Name")

    header.selectAll("th")
      .data((d) -> d)
      .enter().append("th")
      .text((d) -> d.name)

  updateTable = () ->

    table = d3.select("#table").select("tbody")
      
    tableAll = table.selectAll("tr")
      .data(data, (d) -> d["Name"])

    tableAll.exit().remove()
      
    tableEnter = tableAll.enter()

    tableRow = tableEnter.append("tr")
      .attr("id", (d) -> "row_#{d.id}")

    tableRow.append("td").text((d) -> d["Name"])

    tableRow.selectAll("td")
      .data((d) -> d.run).enter()
      .append("td")
      .text((d) -> d.time)

  update = () ->

    yMin = d3.min(data, (d) -> d3.min(d.run.map (e) -> e.time))
    yMax = d3.max(data, (d) -> d3.max(d.run.map (e) -> e.time))
    yExtent = [yMin, yMax]
    yScale.domain(yExtent)

    lines.select(".y.axis")
      .call(yAxis)

    updateTable()

    runData = lines.selectAll(".runs")
      .data(data, (d) -> d["Name"])

    runData.exit().transition().remove()


    runs = runData.enter()
      .append("g")
      .attr("class", "runs")

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
      .attr("cy", (d) ->  yScale(d.time))
      .attr("r", 4)
      .attr("class", "run")
      .attr("fill", "steelblue")
      .on("mouseover", showDetailsPoint)
      .on("mouseout", hideDetailsPoint)

    runPoints.transition().duration(2000).attr("r",4)
      .attr("cx", (d,i) -> xScale(i))
      .attr("cy", (d) ->  yScale(d.time))

  highlightTable = (d,i, highlighted) ->
    table = d3.select("#table")
    table.selectAll("#row_#{d.id}").classed("highlight", highlighted)

  highlightMap = (d, highlighted) ->
    d3.select("#map ##{d.path}").classed("highlight", highlighted)
    d.points.forEach (p) -> d3.select("#map ##{p}").classed("highlight", highlighted)

  highlightPath = (el, highlighted) ->
    d3.select(el).select("path").classed("highlight", highlighted)

  highlightPoint = (el, highlighted) ->
    d3.select(el).classed("highlight", highlighted)

  showInfo = (d,i) ->
    details.html("<h4>#{d.parent["Name"]}</h4><p><strong>#{d.name}:</strong> #{d.time} min</p>")
    details.classed("hidden",false)
    details.classed("faded",false)


  hideInfo = (d,i) ->
    details.classed("faded", true)

  showDetailsPoint = (d,i) ->
    highlightPoint(this, true)
    highlightPath(this.parentNode, true)
    highlightMap(d, true)
    showInfo(d,i)
    highlightTable(d.parent,0,true)


  hideDetailsPoint = (d,i) ->
    highlightPoint(this, false)
    highlightPath(this.parentNode, false)
    highlightMap(d, false)
    hideInfo(d,i)
    highlightTable(d.parent,0,false)

  showDetailsPath = (d,i) ->
    highlightPath(this.parentNode, true)
    highlightTable(d,i,true)

  hideDetailsPath = (d,i) ->
    highlightPath(this.parentNode, false)
    highlightTable(d,i,false)

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

