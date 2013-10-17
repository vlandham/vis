
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


VoronoiColorTreeMap = () ->
  width = 500
  height = 500
  margin = {top: 5, right: 20, bottom: 5, left: 160}
  user_id = -1
  vis = null
  svg = null
  allData = []
  data = []

  voronize = true

  voronoi = d3.geom.voronoi()
    .clipExtent([[0, 0], [width, height]])
    .x((d) -> d.midX)
    .y((d) -> d.midY)

  treemap = d3.layout.treemap()
    .sort((a,b) -> a.value - b.value)
    .mode('squarify')

  filterData = (rawData) ->
    if user_id < 0
      user_id = rawData[0].id
    data = rawData.filter (d) -> d.id == user_id
    data = data[0]
    
  arrangeData = (data) ->
    fakeHierarchy = {'name':'all', 'children':[]}
    data.forEach (d,i) ->
      fakeHierarchy.children.push({'name': d.name, 'color': d.rgb_string, 'value': d.count})
    fakeHierarchy

  chart = (selection) ->
    selection.each (rawData) ->
      allData = rawData
      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      # vis = d3.select(this)
      #   .style("position", "relative")
      #   .style("width", (width + margin.left + margin.right) + "px")
      #   .style("height", (height + margin.top + margin.bottom) + "px")
      #   .style("left", margin.left + "px")
      #   .style("top", margin.top + "px")
      # g.append("rect")
      #   .attr("width", width)
      #   .attr("height", height)
      #   .attr("stroke-fill", "none")
      #   .attr("fill", "none")

      vis = g.append("g").attr("class", "vis_treemap")
      update()

  polygon = (d) ->
    "M" + d.join("L") + "Z"

  midpoints = (dd) ->
    mids = []
    treemap(dd).forEach (d,i) ->
      d.midX = d.x + (d.dx / 2)
      d.midY = d.y + (d.dy / 2)
      if i > 0
        mids.push(d)
    mids

  position = (d) ->
    this.style("left", (d) -> d.x + "px")
      .style("top", (d) -> d.y + "px")
      .style("width", (d) -> Math.max(0, d.dx - 1) + "px")
      .style("height", (d) -> Math.max(0, d.dy - 1) + "px")

  update = () ->
    treemap.size([width, height])
    data = filterData(allData)
    data = arrangeData(data.colors)
    data = midpoints(data)

    v = vis.selectAll('.node')
      .data(voronoi(data))
    v.enter()
      # .append("rect")
      .append("path")
      .attr("class", "node")

    v.exit().remove()

    v.attr("d", polygon)
      .attr("fill", (d,i) -> data[i].color)
    # ps = vis.selectAll(".mid")
    #   .data(data)
    #   .enter()
    #   .append("circle")
    #   .attr("cx", (d) -> d.midX)
    #   .attr("cy", (d) -> d.midY)
    #   .attr('r', 3)
    #   .attr("fill", 'white')
    #   .style("fill", (d) -> d.color)
    # v.attr("x", (d) -> d.x)
    #   .attr("y", (d) -> d.y)
    #   .attr("width", (d) -> d.dx)
    #   .attr("height", (d) -> d.dy)
    #   .style("fill", (d) -> d.color)

  chart.updateDisplay = (_) ->
    user_id = _
    update()
    chart

  chart.id = (_) ->
    if !arguments.length
      return user_id
    user_id = _
    chart

  chart.weight = (_) ->
    if !arguments.length
      return weight
    weight = _
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

  return chart


ColorTreeMap = () ->
  width = 500
  height = 500
  margin = {top: 5, right: 20, bottom: 5, left: 160}
  user_id = -1
  vis = null
  svg = null
  allData = []
  data = []

  treemap = d3.layout.treemap()
    .sort((a,b) -> a.value - b.value)
    .mode('squarify')

  filterData = (rawData) ->
    if user_id < 0
      user_id = rawData[0].id
    data = rawData.filter (d) -> d.id == user_id
    data = data[0]
    
  arrangeData = (data) ->
    fakeHierarchy = {'name':'all', 'children':[]}
    data.forEach (d,i) ->
      fakeHierarchy.children.push({'name': d.name, 'color': d.rgb_string, 'value': d.count})
    fakeHierarchy

  chart = (selection) ->
    selection.each (rawData) ->
      allData = rawData
      # svg = d3.select(this).selectAll("svg").data([data])
      # gEnter = svg.enter().append("svg").append("g")
      
      # svg.attr("width", width + margin.left + margin.right )
      # svg.attr("height", height + margin.top + margin.bottom )

      # g = svg.select("g")
        # .attr("transform", "translate(#{margin.left},#{margin.top})")

      vis = d3.select(this)
        .style("position", "relative")
        .style("width", (width + margin.left + margin.right) + "px")
        .style("height", (height + margin.top + margin.bottom) + "px")
        .style("left", margin.left + "px")
        .style("top", margin.top + "px")
      # g.append("rect")
      #   .attr("width", width)
      #   .attr("height", height)
      #   .attr("stroke-fill", "none")
      #   .attr("fill", "none")

      # vis = g.append("g").attr("class", "vis_treemap")
      update()

  position = (d) ->
    this.style("left", (d) -> d.x + "px")
      .style("top", (d) -> d.y + "px")
      .style("width", (d) -> Math.max(0, d.dx - 1) + "px")
      .style("height", (d) -> Math.max(0, d.dy - 1) + "px")


  update = () ->
    treemap.size([width, height])
    data = filterData(allData)
    data = arrangeData(data.colors)

    v = vis.selectAll('.node')
      .data(treemap(data))
    v.enter()
      .append("div")
      .attr("class", "node")
    v.exit().remove()
    v.call(position)
      .style("position", 'absolute')
      .style("background", (d) -> d.color)

  chart.updateDisplay = (_) ->
    user_id = _
    update()
    chart

  chart.id = (_) ->
    if !arguments.length
      return user_id
    user_id = _
    chart

  chart.weight = (_) ->
    if !arguments.length
      return weight
    weight = _
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

  return chart

StackedArea = () ->
  width = 200
  height = 500
  margin = {top: 5, right: 20, bottom: 5, left: 160}
  user_id = -1
  vis = null
  svg = null
  allData = []
  data = []

  h = d3.scale.linear()
    .range([0, height])

  weight = (d) -> d.count
  maxColors = 20
  maxWeight = 0.85

  filterData = (rawData) ->
    if user_id < 0
      user_id = rawData[0].id
    data = rawData.filter (d) -> d.id == user_id
    data = data[0]

  restrictData = (filteredData) ->
    sortedData = filteredData.sort((a,b) -> weight(b) - weight(a))
    restricted = sortedData
    restricted = []
    totalWeight = sortedData.map((d) -> weight(d)).reduce((p,c) -> p + c)
    console.log(totalWeight)
    curWeight = 0

    for d in sortedData
      curWeight += weight(d)
      restricted.push(d)
      if (curWeight / totalWeight) >= maxWeight
        break

    h.domain([0, curWeight])

    if restricted.length > maxColors
      console.log('still too big ' + restricted.length)
      console.log("removed  #{sortedData.length - restricted.length}")
    restricted

  chart = (selection) ->
    selection.each (rawData) ->

      console.log('stacked')
      allData = rawData

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      g.append("rect")
        .attr("width", width)
        .attr("height", height)
        .attr("stroke-fill", "none")
        .attr("fill", "none")

      vis = g.append("g").attr("class", "vis_stacked")
      update()


  update = () ->
    data = filterData(allData)
    data = restrictData(data.colors)
    # vis.selectAll(".stack").data([]).exit().remove()
    
    v = vis.selectAll(".stack")
      .data(data)

    v.enter().append("rect")
      .attr("width", width)
      .attr("x", 0)
      .attr("class", "stack")

    totalHeight = 0.0
    v.attr "y", (d,i) ->
        height = h(weight(d))
        myY = totalHeight
        totalHeight += height
        myY
      .attr "height", (d,i) ->
        height = h(weight(d))
        height
      .attr("fill", (d) -> d.rgb_string)

    v.exit().remove()
      

  chart.updateDisplay = (_) ->
    user_id = _
    update()
    chart

  chart.id = (_) ->
    if !arguments.length
      return user_id
    user_id = _
    chart

  chart.weight = (_) ->
    if !arguments.length
      return weight
    weight = _
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

  return chart

Squares = () ->
  width = 800
  height = 500
  margin = {top: 5, right: 20, bottom: 5, left: 160}
  points = null
  svg = null

  allData = []
  data = []
  squareSize = 50
  squaresPerRow = 10
  squarePadding = 1
  user_id = -1

  filterData = (rawData) ->
    if user_id < 0
      user_id = rawData[0].id
    data = rawData.filter (d) -> d.id == user_id
    data = data[0]

    data = data.colors.sort (a,b) ->
      b.count - a.count
      # labValue(b) - labValue(a)
    data

  chart = (selection) ->
    selection.each (rawData) ->

      allData = rawData
      data = filterData(allData)

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      g.append("rect")
        .attr("width", width)
        .attr("height", height)
        .attr("stroke-fill", "none")
        .attr("fill", "none")

      points = g.append("g").attr("id", "vis_squares")
      update()

  update = () ->
    height = Math.ceil((data.length / squaresPerRow)) * (squareSize + (squarePadding * 2))
    svg.attr("height", height + margin.top + margin.bottom )
    p = points.selectAll(".square")
      .data(data)
    p.enter()
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
      .attr("fill", (d) -> d.rgb_string)

    p.exit().remove()

    p.attr("fill", (d) -> d.rgb_string)
      
    $('svg .square').tipsy({
      gravity:'w'
      html:true
      title: () ->
        d = this.__data__
        "<strong>#{d.name}</strong> - #{d.rgb_string} - count: #{d.count} - weighted: #{d.weighted_count}"
    })

  chart.updateDisplay = (_) ->
    user_id = _
    data = filterData(allData)
    update()
    chart

  chart.id = (_) ->
    if !arguments.length
      return user_id
    user_id = _
    chart

  return chart


Triangles = () ->
  width = 800
  height = 550
  user_id = -1
  paddingY = width * 0.01
  topR = width * 0.2
  midR = (topR * 2) * 0.25
  tiers = [{id: 1, x: width / 2, y: height / 5 + topR / 4, r: topR, index: 0},
           {id: 2, x: (midR * 3  - midR / 2 - 10), y: (height / 5 ) + topR + (topR / 4) + paddingY, r: midR, index:0},
           {id: 3, x: (midR * 2 - midR / 2 ), y: (height / 5) + topR + (topR / 4) + (midR * 1.60) + paddingY, r: midR, index:0}]
  data = []
  allData = []
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
    t.attr("fill", (d) -> d.rgb_string)

  filterData = (rawData, user_id) ->
    if user_id < 0
      user_id = rawData[0].id
    data = allData.filter (d) -> d.id == user_id
    data = data[0]
    # data = data.sort (a,b) -> +a.rank - +b.rank
    data = data.colors.filter (d,i) -> i < 13
    data

  chart = (selection) ->
    selection.each (rawData) ->

      allData = rawData
      data = filterData(allData, user_id)

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
        .attr("fill", (d) -> d.rgb_string)
        .on("mouseover", mouseover)
        .on("mouseout", mouseout)

  update = () ->
    data = filterData(allData, user_id)
    p = points.selectAll(".triangle")
      .attr("fill", (d) -> d.rgb_string)

    p = points.selectAll(".triangle")
      .data(data)

    p.attr("fill", (d) -> d.rgb_string)


  chart.updateDisplay = (_) ->
    user_id = _
    update()
    chart

  chart.id = (_) ->
    if !arguments.length
      return user_id
    user_id = _
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

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)

openSearch = (e) ->
  $('#search_user').show('slide').select()
  $('#change_nav_link').hide()
  d3.event.preventDefault()

hideSearch = () ->
  $('#search_user').hide()
  $('#change_nav_link').show()

changeUser = (user) ->
  id = root.all.get(user)
  if id
    location.replace("#" + encodeURIComponent(id))
  # d3.event.preventDefault()
  return user

setupSearch = (all) ->
  root.all = d3.map()
  all.forEach (a,i) ->
    root.all.set(a.id, a.id)

  users = root.all.keys()
  # console.log(users)
  $('#search_user').typeahead({local:users, updater:changeUser})

$ ->
  d3.select("#change_nav_link")
    .on("click", openSearch)

  user_id = decodeURIComponent(location.hash.substring(1)).trim()

  if !user_id
    user_id = -1


  plot = Triangles()
  plot.id(user_id)

  square_plot = Squares()
  square_plot.id(user_id)

  stacked_count = StackedArea()
  stacked_count.id(user_id)

  stacked_weight = StackedArea()
  stacked_weight.id(user_id)
  stacked_weight.weight((d) -> d.weighted_count)

  vtreemap = VoronoiColorTreeMap()
  vtreemap.id(user_id)

  treemap = ColorTreeMap()
  treemap.id(user_id)


  display = (error, data) ->
    setupSearch(data)
    plotData("#vis", data, plot)
    plotData("#squares", data, square_plot)
    plotData("#stacked_count", data, stacked_count)
    plotData("#stacked_weight", data, stacked_weight)
    plotData("#vtreemap", data, vtreemap)
    plotData("#treemap", data, treemap)

  queue()
    # .defer(d3.tsv, "data/color_palettes_rgb.txt")
    .defer(d3.json, "data/user_colors.json")
    .await(display)

  updateActive = (new_id) ->
    user_id = new_id
    plot.updateDisplay(user_id)
    square_plot.updateDisplay(user_id)
    stacked_count.updateDisplay(user_id)
    stacked_weight.updateDisplay(user_id)
    treemap.updateDisplay(user_id)

  hashchange = () ->
    console.log('hashchange')
    id = decodeURIComponent(location.hash.substring(1)).trim()
    updateActive(id)


  d3.select(window)
    .on('typeahead:selected', (d) -> console.log('type'))

  d3.select(window)
    .on("hashchange", hashchange)
