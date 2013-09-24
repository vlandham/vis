
root = exports ? this

sin30 = Math.pow(3,1/2)/2
cos30 = 0.5



euclideanDistance = (a, b) ->
  d = Math.sqrt(Math.pow((b[0] - a[0]), 2) + Math.pow((b[1] - a[1]), 2) + Math.pow((b[2] - a[2]), 2))
  d


rgbDiff = (c) ->
  rgb1 = d3.rgb( c.color1)
  rgb2 = d3.rgb( c.color2)
  rgb1Array = [rgb1.r, rgb1.g, rgb1.b]
  rgb2Array = [rgb2.r, rgb2.g, rgb2.b]
  d = euclideanDistance(rgb1Array, rgb2Array)
  d

labDiff = (c) ->
  lab1 = d3.lab( c.color1)
  lab2 = d3.lab( c.color2)
  lab1Array = [lab1.l, lab1.a, lab1.b]
  lab2Array = [lab2.l, lab2.a, lab2.b]
  d = euclideanDistance(lab1Array, lab2Array)
  d


labValue = (d) ->
  lab = d3.lab("rgb(#{d.r},#{d.g},#{d.b})")
  lab.l + lab.a + lab.b

bubbleSort = (a, callback) ->
  sorted = true
  for i in [0..a.length] by i
    if callback(a[i]) > callback(a[i + 1])
      temp = a[i]
      a[i] = a[i + 1]
      a[i + 1] = temp
      sorted = false
  sorted

Squares = () ->
  width = 800
  height = 500
  margin = {top: 5, right: 20, bottom: 5, left: 160}
  squareSize = 50
  squaresPerRow = 10
  squarePadding = 1

  chart = (selection) ->
    selection.each (rawData) ->

      data = rawData.filter (d) -> d.cust_skey == rawData[0].cust_skey

      data = data.sort (a,b) ->
        labValue(b) - labValue(a)

      console.log(data.length)

      # data = data.sort (a,b) -> +a.rank - +b.rank

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      g.append("rect")
        .attr("width", width)
        .attr("height", height)
        .attr("stroke-fill", "none")
        .attr("fill", "none")

      points = g.append("g").attr("id", "vis_squares")

      points.selectAll(".square")
        .data(data).enter()
        .append("rect")
        .attr("class", "square")
        .attr("width", squareSize)
        .attr("height", squareSize)
        .attr "y", (d,i) ->
          row = (Math.ceil((i + 1) / squaresPerRow) - 1)
          row * (squareSize + squarePadding)
        .attr "x", (d,i) ->
          row = Math.ceil((i + 1) / squaresPerRow)
          col = i - ((row - 1) * squaresPerRow)
          col * (squareSize + squarePadding)
        .attr("fill", (d) -> "rgb(#{d.r},#{d.g},#{d.b})")
        # .on("mouseover", mouseover)
        # .on("mouseout", mouseout)
        #
    $('svg .square').tipsy({
      gravity:'w'
      html:true
      title: () ->
        d = this.__data__
        "<strong>#{d.color_name}</strong> - rgb(#{d.r},#{d.g},#{d.b})"
    })
      

  return chart


Triangles = () ->
  width = 800
  height = 550
  paddingY = width * 0.01
  topR = width * 0.2
  midR = (topR * 2) * 0.25
  tiers = [{id: 1, x: width / 2, y: height / 5 + topR / 4, r: topR, index: 0},
           {id: 2, x: (midR * 3  - midR / 2 - 10), y: (height / 5 ) + topR + (topR / 4) + paddingY, r: midR, index:0},
           {id: 3, x: (midR * 2 - midR / 2 ), y: (height / 5) + topR + (topR / 4) + (midR * 1.60) + paddingY, r: midR, index:0}]
  data = []
  points = null
  margin = {top: 25, right: 20, bottom: 0, left: 20}

  tier = (d,i) ->
    if i == 0
      t = tiers[0]
    else if i > 0 and i < 6
      t = tiers[1]
    else
      t = tiers[2]
    t

  coords = (d,i,flip) ->
    t = tier(d,i)
    t.index = t.index + 1
    c = {id:t.id, x:t.x, y:t.y, r: t.r}
    if c.id > 1
      c.x = (t.x) + ((midR - (midR / 8))  * t.index)
      if flip
        c.y = c.y - midR / 2
    c

  trianglePath = (x, y, r, flip) ->
    if flip
      "M#{x - r * sin30} #{y - r * cos30} L #{x + r * sin30} #{y - r * cos30} L #{x} #{y + r} Z"
    else
      "M#{x} #{y - r} L #{x - r * sin30} #{y + r * cos30} L #{x + r * sin30} #{y + r * cos30} Z"

  createPath = (d,i) ->
    d.attr "d", (d, i) ->
      flip = false
      if i > 5
        flip = (i % 2 == 1)
      else if i > 0
        flip = (i % 2 == 0)
      # flip = (i > 0 and (i % 2 == 0)) or (i > 5 and (i % 2 == 1))
      c = coords(d,i,flip)
      trianglePath(c.x, c.y, c.r, flip)

  triangle = (root, x, y, r) ->
    root.append("path")
      .attr("d", trianglePath(x,y,r))


  mouseover = (d,i) ->
    t = d3.select(this)
    t.attr("fill", (d) -> d3.hsl(t.attr("fill")).darker(1))

  mouseout = (d,i) ->
    t = d3.select(this)
    t.attr("fill", (d) -> "rgb(#{d.r},#{d.g},#{d.b})")

  chart = (selection) ->
    selection.each (rawData) ->

      data = rawData.filter (d) -> d.cust_skey == rawData[0].cust_skey
      # data = data.sort (a,b) -> +a.rank - +b.rank
      data = data.filter (d,i) -> i < 13

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      g.append("rect")
        .attr("width", width)
        .attr("height", height)
        .attr("stroke-fill", "none")
        .attr("fill", "none")

      points = g.append("g").attr("id", "vis_points")

      points.selectAll(".triangle")
        .data(data).enter()
        .append("path")
        .attr("class", "triangle")
        .call(createPath)
        .attr("fill", (d) -> "rgb(#{d.r},#{d.g},#{d.b})")
        .on("mouseover", mouseover)
        .on("mouseout", mouseout)

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



root.Triangles = Triangles

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)


$ ->

  plot = Triangles()
  square_plot = Squares()
  display = (error, data) ->
    plotData("#vis", data, plot)
    plotData("#squares", data, square_plot)

  queue()
    .defer(d3.tsv, "data/color_palettes_rgb.txt")
    .await(display)

