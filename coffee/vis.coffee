root = exports ? this

Plot = () ->
  width = 400
  height = 400
  outerRadius = 150
  innerRadius = 0
  rotate = 210
  buffer = 3
  data = []
  vis = null
  margin = {top: 20, right: 20, bottom: 20, left: 20}
  
  maxDomain = 250

  angle = d3.scale.linear()
    .range([0, 2 * Math.PI])
    .domain([1,13])


  radius = d3.scale.linear()
    .range([innerRadius, outerRadius])

  line = d3.svg.line.radial()
    .interpolate("linear-closed")
    .radius((d) -> radius(d.count))
    .angle((d) -> angle(d.index))

  area = d3.svg.area.radial()
    .interpolate(line.interpolate())
    .innerRadius(radius(0))
    .outerRadius(line.radius())
    .angle(line.angle())

  transformData = (rawData) ->
    rawData.data.forEach (d, i) ->
      d.count = parseFloat(d.count)
      d.index = i + 1
      d.month = d.month.toUpperCase()
    rawData

  chart = (selection) ->
    selection.each (rawData) ->

      data = transformData(rawData)

      # angle.domain([1, 13])
      radius.domain([0, d3.max(data.data, (d) -> d.count)])
      radius.domain([0, maxDomain])

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      vis = g.append("g").attr("class", "vis_g")
        .attr("transform", "translate(#{width / 2},#{height / 2})rotate(#{rotate})")
      
      update()

  update = () ->

    layer = vis.selectAll(".layer")
      .data([data]).enter()
      .append("path")
      .attr("class", "layer")
      .attr("d", (d) -> area(d.data))
      .attr("fill", (d) -> "url(#lines-tight-pattern)")
      .attr("stroke", "black")
      .attr("stroke-width", 2)

    axis =vis.selectAll(".axis")
      .data(data.data)
      .enter()
      .append("g")
      .attr("class", "axis")
      .attr("transform", (d) -> "rotate(#{rotate + (angle(d.index - 1) * 180 / Math.PI)})")
    axis.append("line")
      .attr("x1", 0)
      .attr("x2", 0)
      .attr("y1", 0)
      .attr("y2", outerRadius + buffer)
      .attr("stroke", "black")
      .attr("stroke-width", 1.5)

    axis.append("text")
      .attr("class", "names")
      .attr("y", outerRadius + buffer + 5)
      .attr("dy", (d,i) -> if d.index > 2 and d.index < 9 then "-0.2em" else "0.9em")
      .attr("text-anchor", "middle")
      .attr("transform", (d,i) -> if d.index > 2 and d.index < 9 then "rotate(180 #{0},#{outerRadius + buffer + 5})" else null)
      .text((d,i) -> d.month)

    # axis.append("line")
    #   .attr("x1", -50)
    #   .attr("x2", -50)
    #   .attr("y1", outerRadius)
    #   .attr("y2", outerRadius + buffer)
    #   .attr("stroke", "black")
    #   .attr("stroke-width", 1.5)

    arc = d3.svg.arc()
      .innerRadius(outerRadius + buffer)
      .outerRadius(outerRadius + buffer + 25)

    donut = d3.layout.pie().sort(null)
      .value((d) -> 1)

    vis.append("g").attr("transform", "rotate(15)")
      .selectAll("g.arc")
      .data(donut(data.data))
      .enter().append("g")
      .attr("class", "arc")
      .append("path")
      .attr("fill", "none")
      .attr("stroke", "black")
      .attr("stroke-width", 3)
      .attr("d", arc)

    vis.append("circle")
      .attr("cx", 0)
      .attr("cy", 0)
      .attr("r", outerRadius + buffer - 8)
      .attr("class", "ring")

    # vis.append("circle")
    #   .attr("cx", 0)
    #   .attr("cy", 0)
    #   .attr("r", outerRadius + buffer)
    #   .attr("class", "ring")

    # vis.append("circle")
    #   .attr("cx", 0)
    #   .attr("cy", 0)
    #   .attr("r", outerRadius + buffer + 25)
    #   .attr("class", "ring")
  chart.max = (_) ->
    maxDomain = _
    chart

  return chart

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)

$ ->

  svg = d3.select("#vis").append("svg")
    .attr("width", 800)
    .attr("height", 300)


  defs = svg.append("defs")

  hatch1 = defs.append("pattern")
    .attr("id", "lines-tight-pattern")
    .attr("patternUnits", "userSpaceOnUse")
    .attr("patternTransform", "rotate(#{-210})")
    .attr("x", 0)
    .attr("y", 2)
    .attr("width", 5)
    .attr("height", 3)
    .append("g")
  hatch1.append("path")
    .attr("d", "M0 0 H 5")
    .style("fill", "none")
    .style("stroke", "#000")
    .style("stroke-width", 1.6)

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
    .style("stroke", "red")
    .style("stroke-width", 1)
  diag.append("path")
    .attr("d", "M5 0 l-5 5")
    .style("fill", "none")
    .style("stroke", "red")
    .style("stroke-width", 1)
    

  dots = defs.append("pattern")
    .attr("id", "circles-pattern")
    .attr("patternUnits", "userSpaceOnUse")
    .attr("x", 10)
    .attr("y",10)
    .attr("width", 10)
    .attr("height", 10)
    .append("circle")
    .attr("cx", 4)
    .attr("cy", 4)
    .attr("r", 3)
    .attr("fill", "skyblue")

  patterns = ["lines-tight-pattern", "circles-pattern", "diag-pattern"]

  rects = svg.selectAll("rect").data(patterns)

  rects.enter().append("path")
    .attr("d", "M0 0 l50 10 l40 -20 l80 50 l40 80 l-120 -80 l-80 60z")
    .attr("fill", (d) -> "url(##{d})")
    .attr("transform", (d,i) -> "translate(#{5 + (230 * i)},#{50})")
    .style("stroke", "black")
    .style("stroke-width", 2)

  plots = []
  plot = Plot()
  display = (data) ->

    data.forEach (d,i) ->
      d3.select("#chart").append("div").attr("id", d.id).attr("class", "radar")
      plot = Plot()
      if d.disease == "scarlet"
        plot.max(150)
      else if d.id == "under_5_total"
        plot.max(180)
      else if d.id == "all_ages_total"
        plot.max(200)
      else if d.id == "over_60_total"
        plot.max(150)
      plots.push(plot)
      plotData("##{d.id}", d, plot)

  d3.json("data/mortality.json", display)
