
root = exports ? this


angle = (x, y) ->
  (x < 0) * 180 + Math.atan(-y / -x) * 180 / pi

SimpleBubbles = () ->
  width = 1000
  height = 1000
  margin = {top: 0, right: 0, bottom: 0, left: 0}
  user_id = -1
  vis = null
  svg = null
  node = null
  picker = null
  allData = []
  data = []

  minRadius = 6
  maxRadius = 70

  rScale = d3.scale.sqrt().range([minRadius, maxRadius])

  charge = (node) -> -Math.pow(node.radius, 2.0) / 8

  force = d3.layout.force()
    .size([width, height])
    .gravity(0.1)
    .friction(0.9)
    .charge(charge)

  filterData = (rawData) ->
    if user_id < 0
      user_id = rawData[0].id
    data = rawData.filter (d) -> d.id == user_id
    data = data[0]

  setupData = (rawData) ->
    rawData = rawData.filter (d) -> !d.grayscale
    extent = d3.extent(rawData, (d) -> d.weighted_count)
    rScale.domain([0, extent[1]])
    rawData.forEach (d,i) ->
      d.radius = rScale(d.weighted_count)
      d.id = d.name
    rawData

  chart = (selection) ->
    selection.each (rawData) ->
      allData = rawData
      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      vis = g.append("g").attr("id", "vis_nodes")

      update()

  mouseover = (d) ->
    d3.select(this)
      .attr('stroke-width', 2)
      .attr('stroke', "#333")
  mouseout = (d) ->
    node.selectAll("circle")
      .attr('stroke-width', 0)
  update = () ->
    data = filterData(allData)
    data = setupData(data.colors)

    force
      .nodes(data, (d) -> d.id)
      .on("tick", tick)
      .start()

    node = vis.selectAll(".node")
      .data(force.nodes(), (d) -> d.id)
      # .style("fill", "steelblue")

    node.exit().remove()

    c = node.enter().append("g")
      .attr("class", "node")
      .attr("transform", (d) -> "translate(#{d.x},#{d.y})")
      .append("circle")
      # .attr("cx", (d) -> d.x)
      # .attr("cy", (d) -> d.y)
    node.selectAll("circle").attr("r", (d) -> d.radius)
      .attr("fill", (d) -> d.rgb_string)
      .on("mouseover", mouseover)
      .on("mouseout", mouseout)
      .on('click', (d) -> console.log(d.rgb_string))
      .call(force.drag)

  collide = (node) ->
    r = node.radius + 16
    nx1 = node.x - r
    nx2 = node.x + r
    ny1 = node.y - r
    ny2 = node.y + r
    (quad, x1, y1, x2, y2) ->
      if quad.point && (quad.point != node)
        x = node.x - quad.point.x
        y = node.y - quad.point.y
        l = Math.sqrt(x * x + y * y)
        r = node.radius + quad.point.radius
        if (l < r)
          l = (l - r) / l * .5
          node.x -= x *= l
          node.y -= y *= l
          quad.point.x += x
          quad.point.y += y
      return x1 > nx2 || x2 < nx1 || y1 > ny2 || y2 < ny1

  colorCenter = (c) ->
    pos = picker.coordinates(c)
    pos


  moveToColor = (alpha) ->
    k = alpha * 0.08
    (d) ->
      centerNode = colorCenter(d.rgb_string)
      d.x += (centerNode.x - d.x) * k
      d.y += (centerNode.y - d.y) * k

  tick = (e) ->
    q = d3.geom.quadtree(data)
    # data.forEach (n) ->
    #   q.visit(collide(n))
    node.each(moveToColor(e.alpha))
    node
      .attr("transform", (d) -> "translate(#{d.x},#{d.y})")

  chart.margin = (_) ->
    if !arguments.length
      return margin
    margin = _
    chart

  chart.updateDisplay = (_) ->
    user_id = _
    update()
    chart

  chart.picker = (_) ->
    picker = _
    chart

  chart.id = (_) ->
    if !arguments.length
      return user_id
    user_id = _
    chart

  return chart

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

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)

$ ->
  ww = window.innerWidth
  wh = window.innerHeight
  max = Math.min(ww, wh)
  color = []
  size = max
  size = 1000
  console.log("size: " + size)
  r = size / 5
  console.log("radius: " + r)
  isColorblind = false
  stages = [
      {
        name: "hue",
        dimensions: 1,
        duration: 10000,
        selectors: 1,
        separation: 0
      }]
  stage = stages[0]
  cp = Raphael.colorpicker(0, 0, size, "#fff", "wheel", 0, stage.dimensions, stage.separation, isColorblind)
  cp.color("red")
  d3.select("#change_nav_link")
    .on("click", openSearch)

  user_id = decodeURIComponent(location.hash.substring(1)).trim()

  if !user_id
    user_id = -1

  plot = SimpleBubbles()
  plot.picker(cp)
  plot.id(user_id)

  display = (error, data) ->
    setupSearch(data)
    plotData("#vis", data, plot)



  diplay = (error, data) ->
    setupSearch(data)
    plotData("#vis", data, plot)

  queue()
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
