root = exports ? this

sin30 = Math.pow(3,1/2)/2
cos30 = 0.5

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
  $('#search_user').typeahead({source:users, updater:changeUser})

$ ->
  d3.select("#change_nav_link")
    .on("click", openSearch)

  user_id = decodeURIComponent(location.hash.substring(1)).trim()

  if !user_id
    user_id = -1


  plot = Triangles()
  plot.id(user_id)

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


  d3.select(window)
    .on("hashchange", hashchange)
