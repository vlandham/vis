
root = exports ? this

toPercent = (dec) ->
  Math.round((dec) * 100)

Plot = () ->
  width = 900
  height = 600
  data = []
  points = null
  margin = {top: 40, right: 50, bottom: 20, left: 20}
  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([0,height])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)

  convertData = (all, node, downward, sideward, parent) ->
    percent = 1.0
    exitAmount = 0
    siblingCount = 0
    exitPercent = 0.0
    na = if node.na then node.na else 0
    naPercent = 0.0
    if parent
      percent = node.amount / parent.amount
      exitAmount = parent.amount - (node.amount + na)
      exitPercent = exitAmount / parent.amount
      siblingCount = parent.children.length
      naPercent = na / parent.amount
    all.push({'node':node,'row':downward,'col':sideward, 'percent':percent, 'exit':exitAmount, 'exitPercent':exitPercent, 'amount':node.amount, 'siblingCount':siblingCount, 'na':na, 'naPercent':naPercent})
    if node.children
      node.children.forEach (child, childIndex) ->
        convertData(all, child, downward + 1, sideward + childIndex, node)
    return all

  chart = (selection) ->
    selection.each (rawData) ->

      xScale.domain([0, rawData.amount])

      data = convertData([], rawData, 0, 0, null)
      yScale.domain([0, data.length])
      console.log(data)

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      points = g.append("g").attr("id", "vis_points")
      update()

  update = () ->
    rectHeight = 30
    layerHeight = 80
    layerBuffer = 20
    # TODO: this needs to be data driven
    layerWidth = width / 3

    pointG = points.selectAll(".layer")
      .data(data).enter()
      .append("g")
      .attr("transform", (d) -> "translate(#{d.col * (layerWidth + layerBuffer)},#{d.row * (layerHeight + layerBuffer)})")

    pointG.append("text")
      .text((d) -> d.node.title)
      .attr("class", "title")

    pointG.append("rect")
      .attr("class", "continue")
      .attr("x", 0)
      .attr("y", layerBuffer / 2)
      .attr("width", (d) -> xScale(d.amount))
      .attr("height", rectHeight)

    pointG.append("rect")
      .attr("class", "na")
      .attr("x",(d) -> xScale(d.amount))
      .attr("y", layerBuffer / 2)
      .attr("width", (d) -> xScale(d.na))
      .attr("height", rectHeight)

    pointG.append("rect")
      .attr("class", "exit")
      .attr("x",(d) -> xScale(d.amount + d.na))
      .attr("y", layerBuffer / 2)
      .attr("width", (d) -> xScale(d.exit))
      .attr("height", rectHeight)

    $('svg .exit').tipsy({
      gravity:'n'
      html:true
      title: () ->
        d = this.__data__
        "#{addCommas(d.exit)}<br/>#{toPercent(d.exitPercent)}%"
    })

    $('svg .na').tipsy({
      gravity:'n'
      html:true
      title: () ->
        d = this.__data__
        "#{addCommas(d.na)}<br/>#{toPercent(d.naPercent)}%"
    })

    pointG.append("text")
      .text((d) -> toPercent(d.percent) + "%")
      .attr("class", "percent")
      .attr("x", 0)
      .attr("dx", 5)
      .attr("y", (layerBuffer / 2) + rectHeight / 2 )
      .attr("dy",5)

    pointG.append("text")
      .text((d) -> addCommas(d.amount))
      .attr("class", "num")
      .attr("x", 0)
      .attr("dx", 0)
      .attr("y", (layerBuffer) + rectHeight )
      .attr("dy",5)

    pointG.append("text")
      .attr("class", "note")
      .attr("x", 0)
      .attr("y", layerBuffer + rectHeight + 20)
      .text((d) -> d.node.note)

    keyData = [{"name":"True", "class":"continue"}, {"name":"False", "class":"exit"}, {"name":"N/A", "class":"na"}]
    key = points.append("g")
      .attr("transform", "translate(0,#{(data[data.length - 1].row + 1) * (layerHeight + layerBuffer)})")

    keys = key.selectAll(".key")
      .data(keyData).enter()
      .append("g")
      .attr("transform", (d,i) -> "translate(0,#{30 * i})")
      .attr("class", "key")
    keys.append("rect")
      .attr("width", 20)
      .attr("height", 20)
      .attr("class", (d) -> "#{d.class}")

    keys.append("text")
      .attr("x", 20)
      .attr("dx", 5)
      .attr("y", 10)
      .attr("dy", 5)
      .text((d) -> d.name)

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
    .defer(d3.json, "data/returns_tree.json")
    .await(display)

