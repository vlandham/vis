root = exports ? this

sin30 = Math.pow(3,1/2)/2
cos30 = 0.5

# Help with the placement of nodes
RadialPlacement = () ->
  # stores the key -> location values
  values = d3.map()
  # how much to separate each location by
  increment = 20
  # how large to make the layout
  radius = 200
  # where the center of the layout should be
  center = {"x":0, "y":0}
  # what angle to start at
  start = -120
  current = start

  # Given an center point, angle, and radius length,
  # return a radial position for that angle
  radialLocation = (center, angle, radius) ->
    x = (center.x + radius * Math.cos(angle * Math.PI / 180))
    y = (center.y + radius * Math.sin(angle * Math.PI / 180))
    {"x":x,"y":y}

  # Main entry point for RadialPlacement
  # Returns location for a particular key,
  # creating a new location if necessary.
  placement = (key) ->
    value = values.get(key)
    if !values.has(key)
      value = place(key)
    value

  # Gets a new location for input key
  place = (key) ->
    value = radialLocation(center, current, radius)
    values.set(key,value)
    current += increment
    value

   # Given a set of keys, perform some 
  # magic to create a two ringed radial layout.
  # Expects radius, increment, and center to be set.
  # If there are a small number of keys, just make
  # one circle.
  setKeys = (keys) ->
    # start with an empty values
    values = d3.map()
  
    # number of keys to go in first circle
    firstCircleCount = 360 / increment

    # if we don't have enough keys, modify increment
    # so that they all fit in one circle
    if keys.length < firstCircleCount
      increment = 360 / keys.length

    # set locations for inner circle
    firstCircleKeys = keys.slice(0,firstCircleCount)
    firstCircleKeys.forEach (k) -> place(k)

    # set locations for outer circle
    secondCircleKeys = keys.slice(firstCircleCount)

    # setup outer circle
    radius = radius + radius / 1.8
    increment = 360 / secondCircleKeys.length

    secondCircleKeys.forEach (k) -> place(k)

  placement.keys = (_) ->
    if !arguments.length
      return d3.keys(values)
    setKeys(_)
    placement

  placement.center = (_) ->
    if !arguments.length
      return center
    center = _
    placement

  placement.radius = (_) ->
    if !arguments.length
      return radius
    radius = _
    placement

  placement.start = (_) ->
    if !arguments.length
      return start
    start = _
    current = start
    placement

  placement.increment = (_) ->
    if !arguments.length
      return increment
    increment = _
    placement

  return placement

Triangles = () ->
  layout = 'top'
  parent = null
  svg = null
  points = null
  details = null
  width = 800
  height = 500
  aspect = (width) / (height)
  user_id = -1
  paddingY = width * 0.01
  topR = width * 0.2
  midR = (topR * 2) * 0.25
  tiers = [{id: 1, x: width / 2, y: height / 5 + (topR / 4 + (paddingY * 3)), r: topR, index: 0},
           {id: 2, x: (midR * 3  - midR / 2 - 10), y: (height / 5 ) + (topR + (topR / 4) + (paddingY * 3)) + paddingY, r: midR, index:0},
           {id: 3, x: (midR * 2 - midR / 2 ), y: (height / 5) + (topR + (topR / 4) + (paddingY * 3)) + (midR * 1.60) + paddingY, r: midR, index:0}]
  data = []
  allData = []

  minRadius = 8
  maxRadius = topR - 20
  rScale = d3.scale.sqrt().range([minRadius, maxRadius])
  

  tier = (i) ->
    if i == 0
      t = tiers[0]
    else if i > 0 and i < 6
      t = tiers[1]
    else
      t = tiers[2]
    t

  # x, y & r values for a triangle
  # depends on the index of the triangle
  # and if the triangle is flipped or not
  coords = (i,flip) ->
    t = tier(i)
    # TODO: don't modify tier inside coords
    t.index = t.index + 1
    c = {id:t.id, x:t.x, y:t.y, r: t.r}
    if c.id > 1
      c.x = (t.x) + ((midR - (midR / 8))  * t.index)
      if flip
        c.y = c.y - midR / 2
    c

  # trianglePath = (x, y, r, flip) ->
  #   x = 0
  #   y = 0
  #   if flip
  #     "M#{x - r * sin30} #{y - r * cos30} L #{x + r * sin30} #{y - r * cos30} L #{x} #{y + r} Z"
  #   else
  #     "M#{x} #{y - r} L #{x - r * sin30} #{y + r * cos30} L #{x + r * sin30} #{y + r * cos30} Z"

  trianglePath = (r, flip) ->
    x = 0
    y = 0
    if flip
      "M#{x - r * sin30} #{y - r * cos30} L #{x + r * sin30} #{y - r * cos30} L #{x} #{y + r} Z"
    else
      "M#{x} #{y - r} L #{x - r * sin30} #{y + r * cos30} L #{x + r * sin30} #{y + r * cos30} Z"

  flipFor = (d,i) ->
    flip = false
    if i > 5
      flip = (i % 2 == 1)
    else if i > 0
      flip = (i % 2 == 0)
    flip

  showDetails = (d) ->
    xcord = 0
    text = details.append("text")
      .attr("class", "detail_text")
      .attr("x", width - 40)
      .attr("y", d.coords.y)
      .attr("dy", 5)
      .attr("opacity", 1e-6)
      .attr("text-anchor", "end")
      .text(d.name)
      .each((d) -> xcord = this.getBBox().x)

    path = details.append("path")
      .attr("d", "M #{d.coords.x} #{d.coords.y} L #{d.coords.x} #{d.coords.y}")
    path.transition().duration(200)
      .attr("d", "M #{d.coords.x} #{d.coords.y} L #{xcord - 10} #{d.coords.y}")
    text.transition().duration(200)
      .delay(100)
      .attr("opacity", 1)


  hideDetails = (d) ->
    details.select("path").remove()
    details.select("text").remove()

  mouseover = (d,i) ->
    t = d3.select(this)
    t.attr("fill", (d) -> d3.hsl(t.attr("fill")).darker(1))
    showDetails(d)

  mouseout = (d,i) ->
    t = d3.select(this)
    t.attr("fill", (d) -> d.rgb_string)
    hideDetails(d)

  filterData = (rawData, user_id) ->
    if user_id < 0
      user_id = rawData[0].id
    data = allData.filter (d) -> d.id == user_id
    data = data[0]
    # data = data.sort (a,b) -> +a.rank - +b.rank
    data = data.colors.filter (d,i) -> i < 13
    data


  setupData = (data) ->
    rScale.domain(d3.extent(data, (d) -> d.weighted_count))
    data.forEach (d,i) ->
      d.flip = flipFor(d,i)
      d.tier = tier(i)
      d.coords = coords(i, d.flip)
      d.amount_r = rScale(d.weighted_count)

  chart = (selection) ->
    selection.each (rawData) ->

      allData = rawData
      data = filterData(allData, user_id)
      data = setupData(data)

      parent = $(this)
      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")

      svg.attr("viewBox", "0 0 #{width} #{height}")
      svg.attr("preserveAspectRatio", "xMidYMid")
      
      chart.resize()

      g = svg.select("g")

      g.append("rect")
        .attr("width", width)
        .attr("height", height)
        .attr("stroke-fill", "none")
        .attr("fill", "none")

      points = g.append("g").attr("id", "vis_triangles")
      details = g.append("g").attr("id", "vis_details")
      update()


  updateCenters = (artists) ->
    groupCenters = RadialPlacement().center({"x":width/2, "y":height / 2 - 100})
      .radius(300).increment(18).keys(artists)

  update = () ->
    data = filterData(allData, user_id)

    p = points.selectAll(".triangle")
      .data(data)

    gEnter = p.enter()
      .append("g")
      .attr("class", "triangle")
      .attr("transform", (d) -> "translate(#{d.coords.x},#{d.coords.y})")

    t = gEnter.append("path")
      .attr("class", "triangle_path")
      .on("mouseover", mouseover)
      .on("mouseout", mouseout)
      .attr("d", (d, i) -> trianglePath(d.coords.r, d.flip))

    t.attr("fill", (d) -> d.rgb_string)

    if layout == "top"
      p.transition()
        .duration(1000)
        .attr("transform", (d) -> "translate(#{d.coords.x},#{d.coords.y})rotate(#{if d.flip then 120 else 120})")
      p.select(".triangle_path").transition()
        .duration(1000)
        .attr("d", (d, i) -> trianglePath(d.coords.r, d.flip))
    else
      p.transition()
        .duration(1000)
        .attr("transform", (d) -> "translate(#{d.coords.x},#{d.coords.y})rotate(#{if d.flip then 60 else 0})")

      p.select(".triangle_path").transition()
        .duration(1000)
        .attr("d", (d, i) -> trianglePath(d.amount_r, d.flip))

  setLayout = (newLayout) ->
    layout = newLayout
    if layout == "top"
      1 + 1
    else if layout == "amounts"
      1 + 1
  
  chart.toggleLayout = (newLayout) ->
    setLayout(newLayout)
    update()

  # attempt to make vis responsive in design
  # http://stackoverflow.com/questions/9400615/whats-the-best-way-to-make-a-d3-js-visualisation-layout-responsive
  chart.resize = () ->
    targetWidth = parent.width()
    svg.attr("width", targetWidth)
    svg.attr("height", Math.round(targetWidth / aspect))

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


activateButton = (id) ->
  d3.selectAll(".g-menu-button").classed("g-menu-button-selected", false)
  d3.select("##{id}").classed("g-menu-button-selected", true)

$ ->
  d3.select("#change_nav_link")
    .on("click", openSearch)


  user_id = decodeURIComponent(location.hash.substring(1)).trim()

  if !user_id
    user_id = -1


  plot = Triangles()
  plot.id(user_id)

  d3.selectAll("#g-menu-container .g-menu-button").on "click", (d) ->
    id = d3.select(this).attr("id")
    activateButton(id)
    newLayout = id.split("-")[2]
    plot.toggleLayout(newLayout)
    
  display = (error, data) ->
    setupSearch(data)
    plotData("#vis", data, plot)

  queue()
    # .defer(d3.tsv, "data/color_palettes_rgb.txt")
    .defer(d3.json, "data/user_colors.json")
    .await(display)

  updateActive = (new_id) ->
    user_id = new_id
    plot.updateDisplay(user_id)

  hashchange = () ->
    id = decodeURIComponent(location.hash.substring(1)).trim()
    updateActive(id)

  resize = () ->
    plot.resize()


  d3.select(window)
    .on("hashchange", hashchange)

  d3.select(window)
    .on("resize", resize)


