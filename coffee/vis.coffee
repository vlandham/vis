
root = exports ? this

Plot = () ->
  # colors = {"me":"#8D040C","bap":"#322209","pres":"#3D605C","cat":"#2E050B","con":"#4B6655","epi":"#C84914","lut":"#C6581B","chr":"#87090D","oth":"#300809"}
  colors = {"me":"url(#lines_red)","bap":"#3e290e","pres":"#3a5b57","cat":"#30050c","con":"url(#lines_blue)","epi":"#c0410f","lut":"#C6581B","chr":"#85090d","oth":"#310909"}
  width = 1100
  height = 900
  bigSize = 300
  littleSize = 130
  padding = 40
  data = []
  points = null
  margin = {top: 20, right: 20, bottom: 20, left: 20}
  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([0,height])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)
  treeScale = d3.scale.linear().domain([0,100]).range([0,littleSize])
  treemap = d3.layout.treemap()
    .sort((a,b) -> b.index - a.index)
    .children((d) -> d.churches)
    .value((d) -> d.percent)
    .mode('slice')

  processData = (rawData) ->
    rawData.forEach (tre,i) ->
      # the big square takes up two little squares
      tre.index = if tre.size == 'little' then i + 1 else i
      tre.row = if tre.size == 'little' then Math.floor(tre.index / 6) + 1 else 0
      tre.col = tre.index % 6
      tre.realSize = if tre.size == 'little' then littleSize else bigSize
      # this is to keep them in order
      # cause i'm too lazy to use stack
      tre.churches.forEach (c,i) ->
        c.index = i
    rawData

  chart = (selection) ->
    selection.each (rawData) ->

      data = processData(rawData)
      console.log(data)

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")

      defs = svg.append("defs")
      hatch1 = defs.append("pattern")
        .attr("id", "lines_red")
        .attr("patternUnits", "userSpaceOnUse")
        .attr("patternTransform", "rotate(#{-220})")
        .attr("x", 0)
        .attr("y", 2)
        .attr("width", 5)
        .attr("height", 3)
        .append("g")
      hatch1.append("rect")
        .attr("fill", "white")
        .attr("width", 5)
        .attr("height", 3)
      hatch1.append("path")
        .attr("d", "M0 0 H 5")
        .style("fill", "none")
        .style("stroke", "red")
        .style("stroke-width", 3.6)
      hatch2 = defs.append("pattern")
        .attr("id", "lines_blue")
        .attr("patternUnits", "userSpaceOnUse")
        .attr("patternTransform", "rotate(#{-220})")
        .attr("x", 0)
        .attr("y", 2)
        .attr("width", 5)
        .attr("height", 3)
        .append("g")
      hatch2.append("rect")
        .attr("fill", "white")
        .attr("width", 5)
        .attr("height", 3)
      hatch2.append("path")
        .attr("d", "M0 0 H 5")
        .style("fill", "none")
        .style("stroke", "#4B6655")
        .style("stroke-width", 3.6)

      diag = defs.append("pattern")
        .attr("id", "diag-pattern")
        .attr("patternUnits", "userSpaceOnUse")
        .attr("x", 0)
        .attr("y", 3)
        .attr("width", 5)
        .attr("height", 5)
      diag.append("path")
        .attr("d", "M0 0 l5 5")
        .style("fill", "none")
        .style("stroke", "blue")
        .style("stroke-width", 1)
      
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      points = g.append("g").attr("id", "vis_points")
      update()

  update = () ->

    tree = points.selectAll('.tree')
      .data(data).enter().append("g")
      .attr("class","tree")
      .attr "transform", (d,i) ->
        top = d.row * (padding + littleSize)
        "translate(#{(d.col) * (littleSize + padding)},#{top})"
    tree.append("rect")
      .attr("width", (d) -> d.realSize)
      .attr("height", (d) -> d.realSize)
      .attr("x", 0)
      .attr('y', 0)
      .attr('fill', '#6d5d4f')

    tree.append("text")
      .attr("text-anchor", "middle")
      .attr("x", (d) -> d.realSize / 2)
      .attr("y", (d) -> d.realSize)
      .attr('dy', 14)
      .text((d) -> d.name.toUpperCase())


    treeG = tree.append("g")
      .attr "transform", (d) ->
        scale = d.known / 100.0
        trans = (d.realSize - (d.realSize * scale)) / 2
        console.log(trans)
        "translate(#{trans},#{trans})scale(#{scale})"

    treeG.selectAll(".slice")
      .data((d) -> treemap.size([d.realSize, d.realSize])(d)).enter()
      .append("rect")
      .attr('class', (d) -> "slice #{d.name}")
      .attr("x", (d) -> d.x)
      .attr("y", (d) -> d.y)
      .attr("width", (d) -> Math.max(0, d.dx))
      .attr("height", (d) -> Math.max(0, d.dy))
      .attr("fill", (d) -> colors[d.name])



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
    .defer(d3.json, "data/treemap.json")
    .await(display)

