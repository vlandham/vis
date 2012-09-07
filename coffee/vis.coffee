
root = exports ? this

Bubbles = () ->
  width = 970
  height = 540
  data = []
  node = null
  label = null
  margin = {top: 20, right: 10, bottom: 20, left: 10}
  maxRadius = 65

  rScale = d3.scale.sqrt().range([0,maxRadius])
  rValue = (d) -> parseInt(d.count)
  idValue = (d) -> d.name
  textValue = (d) -> d.name

  collisionPadding = 4
  minCollisionRadius = 16
  jitter = 0.5

  tick = (e) ->
    reducedAlpha = e.alpha * 0.1
    node
      .each(gravity(reducedAlpha))
      .each(collide(jitter))
      .attr("transform", (d) -> "translate(#{d.x},#{d.y})")

    label
      .style("left", (d) -> ((margin.left + d.x) - d.dx / 2) + "px")
      .style("top", (d) -> ((margin.top + d.y) - d.dy / 2) + "px")

  force = d3.layout.force()
    .gravity(0)
    .charge(0)
    .size([width, height - 80])
    .on("tick", tick)

  chart = (selection) ->
    selection.each (rawData) ->

      data = transformData(rawData)
      maxCount = d3.max(data, (d) -> d.count)
      rScale.domain([0, maxCount])

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      node = g.append("g").attr("id", "bubble-nodes")

      node.append("rect")
        .attr("id", "bubble-background")
        .attr("width", width)
        .attr("height", height)
        .on("click", clear)

      label = d3.select(this).selectAll("#bubble-labels").data([data])
        .enter()
        .append("div")
        .attr("id", "bubble-labels")

      update()
      hashchange()
      d3.select(window)
        .on("hashchange", hashchange)

  update = () ->
    data.forEach (d,i) ->
      d.forceR = Math.max(12, rScale(rValue(d)))
    force.nodes(data).start()
    updateNodes()
    updateLabels()

  updateNodes = () ->
    node = node.selectAll("bubble-node").data(data, (d) -> idValue(d))
    node.exit().remove()
    node.enter()
      .append("a")
      .attr("class", "bubble-node")
      .attr("xlink:href", (d) -> "##{encodeURIComponent(idValue(d))}")
      .call(force.drag)
      .call(link)
      .append("circle")
      .attr("r", (d) -> rScale(rValue(d)))

  updateLabels = () ->
    label = label.selectAll("bubble-label").data(data, (d) -> idValue(d))

    label.exit().remove()

    labelEnter = label.enter().append("a")
      .attr("class", "bubble-label")
      .attr("href", (d) -> "##{encodeURIComponent(idValue(d))}")
      .call(force.drag)
      .call(link)

    labelEnter.append("div")
      .attr("class", "bubble-label-name")
      .text((d) -> textValue(d))

    labelEnter.append("div")
      .attr("class", "bubble-label-value")
      .text((d) -> d.count)

    label
      .style("font-size", (d) -> Math.max(8, rScale(rValue(d) / 2)) + "px")
      .style("width", (d) -> rScale(rValue(d)) * 2.5 + "px")

    label.append("span")
      .text((d) -> textValue(d))
      .each((d) -> d.dx = Math.max(2.5 * rScale(rValue(d)), this.getBoundingClientRect().width))
      .remove()

    label
      .style("width", (d) -> d.dx + "px")

    label.each((d) -> d.dy = this.getBoundingClientRect().height)

  # custom gravity to skew the bubble placement
  # horizontally
  gravity = (alpha) ->
    cx = width / 2
    cy = height / 2
    ax = alpha / 8
    ay = alpha

    (d) ->
      d.x += (cx - d.x) * ax
      d.y += (cy - d.y) * ay

  collide = (alpha) ->
    q = d3.geom.quadtree(data)
    (d) ->
      r = d.forceR + maxRadius + collisionPadding
      nx1 = d.x - r
      nx2 = d.x + r
      ny1 = d.y - r
      ny2 = d.y + r
      q.visit (quad, x1, y1, x2, y2) ->
        if quad.point && (quad.point != d)
          x = d.x - quad.point.x
          y = d.y - quad.point.y
          l = Math.sqrt(x * x + y * y)
          r = d.forceR + quad.point.forceR + collisionPadding
          if l < r
            l = (l - r) / l * alpha
            x = x * l
            y = y * l
            d.x -= x
            d.y -= y
            quad.point.x += x
            quad.point.y += y
        x1 > nx2 || x2 < nx1 || y1 > ny2 || y2 < ny1
            

  transformData = (rawData) ->
    # occupiedExtent = d3.extent(rawData, (d) -> parseInt(d.total_occupied))
    # countScale = d3.scale.linear().domain(occupiedExtent).range([1,100])
    rawData.forEach (d) ->
      # d.count = countScale(d.total_occupied)
      d.count = parseInt(d.count)
      rawData.sort(() -> 0.5 - Math.random())
    rawData

  link = (d) ->
    d.on("click", click)
    d.on("mouseover", mouseover)
    d.on("mouseout", mouseout)

  clear = () ->
    location.replace("#!")

  click = (d) ->
    location.replace("#" + encodeURIComponent(idValue(d)))
    d3.event.preventDefault()

  mouseover = (d) ->
    node.classed("bubble-hover", (p) -> p == d)

  mouseout = (d) ->
    node.classed("bubble-hover", false)

  hashchange = () ->
    id = decodeURIComponent(location.hash.substring(1)).trim()
    updateActive(id)

  updateActive = (id) ->
    active = id
    console.log(id)
    node.classed("bubble-selected", (d) -> id == idValue(d))

  chart.jitter = (_) ->
    if !arguments.length
      return jitter
    jitter = _
    console.log(jitter)
    force.start()
    chart

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

  chart.r = (_) ->
    if !arguments.length
      return rValue
    rValue = _
    chart

  return chart

root.Bubbles = Bubbles

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)

$ ->

  plot = Bubbles()
  display = (data) ->
    plotData("#vis", data, plot)

  d3.select("#jitter")
    .on "input", () -> 
      plot.jitter(+this.output.value)

  d3.csv("data/words_short.csv", display)

