
root = exports ? this

sin30 = Math.pow(3,1/2)/2
cos30 = 0.5


  
Plot = () ->
  width = 600
  height = 600
  topR = width / 6
  midR = width / 12
  tiers = [{id: 1, x: width / 2, y: height / 5, r: topR},{id: 2, x: midR, y: (height / 5 ) + topR, r: midR}, {id: 3, x: 0, y: height / 4, r: midR}]
  data = []
  points = null
  margin = {top: 20, right: 20, bottom: 20, left: 20}
  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([0,height])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)

  tier = (d,i) ->
    if i == 0
      t = tiers[0]
    else if i > 0 and i < 10
      t = tiers[1]
    else
      t = tiers[2]
    t

  coords = (d,i) ->
    t = tier(d,i)
    if t.id > 1
      t.x = (t.x) + ( midR * i)
    t

  trianglePath = (x, y, r, flip) ->
    if flip
      "M#{x - r} #{y - r} L #{x - r * sin30} #{y + r * cos30} L #{x + r * sin30} #{y + r * cos30} Z"
    else
      "M#{x} #{y - r} L #{x - r * sin30} #{y + r * cos30} L #{x + r * sin30} #{y + r * cos30} Z"

  createPath = (d,i) ->
    d.attr "d", (d, i) ->
      flip = i > 0 and (i % 2 == 0)
      flip = false
      c = coords(d,i)
      trianglePath(c.x, c.y, c.r, flip)

  triangle = (root, x, y, r) ->
    root.append("path")
      .attr("d", trianglePath(x,y,r))

  chart = (selection) ->
    selection.each (rawData) ->

      data = rawData.filter (d) -> d.cust_skey == rawData[0].cust_skey
      data = data.sort (a,b) -> +a.rank - +b.rank

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      g.append("rect")
        .attr("width", width)
        .attr("height", height)
        .attr("stroke-width", 2)
        .attr("stroke-fill", "black")


      points = g.append("g").attr("id", "vis_points")

      points.selectAll(".triangle")
        .data(data).enter()
        .append("path")
        .attr("class", "triangle")
        .call(createPath)
        .attr("fill", (d) -> "rgb(#{d.r},#{d.g},#{d.b})")
      # update()

  update = () ->
    points.selectAll(".point")
      .data(data).enter()
      .append("circle")
      .attr("cx", (d) -> xScale(xValue(d)))
      .attr("cy", (d) -> yScale(yValue(d)))
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
  display = (error, data) ->
    plotData("#vis", data, plot)

  queue()
    .defer(d3.tsv, "data/color_palettes_rgb.txt")
    .await(display)

