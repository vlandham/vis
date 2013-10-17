
root = exports ? this

SimpleBubbles = () ->
  width = 900
  height = 600
  margin = {top: 5, right: 20, bottom: 5, left: 20}
  user_id = -1
  vis = null
  svg = null
  node = null
  allData = []
  data = []

  minRadius = 8
  maxRadius = 80

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

      vis = g.append("g").attr("id", "vis_nodes")

      update()

  update = () ->
    data = filterData(allData)
    data = setupData(data.colors)

    force
      .nodes(data, (d) -> d.id)
      .on("tick", tick)
      .start()

    console.log(force.nodes())
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
      # .on("mouseover", showTags)
      # .on("mouseout", hideTags)
      # .on('click', (d) -> console.log(d))
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

  tick = (e) ->
    q = d3.geom.quadtree(data)
    # data.forEach (n) ->
      # q.visit(collide(n))
    # node.each(moveToTag(e.alpha))
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
  d3.select("#change_nav_link")
    .on("click", openSearch)

  user_id = decodeURIComponent(location.hash.substring(1)).trim()

  if !user_id
    user_id = -1


  plot = SimpleBubbles()


  display = (error, data) ->
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
