
root = exports ? this

BubbleMap = () ->
  width = 938
  height = 500

  data = []

  xy = d3.geo.albersUsa().translate([-2000,1350]).scale(55000)
  path = d3.geo.path().projection(xy)

  node = null
  lines = null
  margin = {top: 0, right: 0, bottom: 0, left: 0}

  maxRadius = 5

  # this scale will be used to size our bubbles
  rScale = d3.scale.sqrt().range([1,maxRadius])

  
  metric_id = "HC02_EST_VC02"

  colorScale = d3.scale.linear().range(["#A6C7E8", "#074E90"])
  colorValue = (d) -> d.properties[metric_id]
  
  # I've abstracted the data value used to size each
  # into its own function. This should make it easy
  # to switch out the underlying dataset
  rValue = (d) -> d.properties[metric_id]

  # function to define the 'id' of a data element
  #  - used to bind the data uniquely to the force nodes
  #   and for url creation
  #  - should make it easier to switch out dataset
  #   for your own
  idValue = (d) -> d.name

  # function to define what to display in each bubble
  #  again, abstracted to ease migration to 
  #  a different dataset if desired
  textValue = (d) -> d.name
  
  transformData = (rawData) ->
    console.log(rawData)
    rawData.forEach (d) ->
      d.pos = xy(d.geometry.coordinates)
      d.properties[metric_id] = if d.properties[metric_id] then parseFloat(d.properties[metric_id]) else 0
      # d.count = parseInt(d.count)
      # rawData.sort(() -> 0.5 - Math.random())
    rawData


  # constants to control how
  # collision look and act
  collisionPadding = 4
  minCollisionRadius = 12

  # variables that can be changed
  # to tweak how the force layout
  # acts
  # - jitter controls the 'jumpiness'
  #  of the collisions
  jitter = 0.5

  # ---
  # tick callback function will be executed for every
  # iteration of the force simulation
  # - moves force nodes towards their destinations
  # - deals with collisions of force nodes
  # - updates visual bubbles to reflect new force node locations
  # ---
  tick = (e) ->
    dampenedAlpha = e.alpha * 0.1
    
    # Most of the work is done by the gravity and collide
    # functions.
    node
      .each(gravity(dampenedAlpha))
      .each(location(dampenedAlpha))
      # .each(collide(jitter))
      .attr("transform", (d) -> "translate(#{d.x},#{d.y})")


  # The force variable is the force layout controlling the bubbles
  # here we disable gravity and charge as we implement custom versions
  # of gravity and collisions for this visualization
  force = d3.layout.force()
    .gravity(0)
    .charge(0)
    .size([width, height])
    .on("tick", tick)


  map = (selection) ->
    selection.each (rawData) ->

      data = transformData(rawData.features)

      maxDomainValue = d3.max(data, (d) -> rValue(d))
      rScale.domain([0, maxDomainValue])

      colorExtent = d3.extent(data, (d) -> colorValue(d))
      console.log(colorExtent)
      colorScale.domain(colorExtent)
      

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      lines = g.append("g").attr("id", "lines")
      node = g.append("g").attr("id", "vis_points")

      d3.json("data/ks_mo_states.json", show_states)
      d3.json("data/kansas_city_counties.json", show_lines)
      update()

  show_lines = (lines_geo) ->
    slines = lines.selectAll(".county_lines").data(lines_geo.features)

    slines.enter()
      .append("path")
      .attr("class", "county_lines")
      .attr("d", path)
      .attr("stroke", "#222")
      .attr("stroke-width", 1)
      .attr("fill", "none")

  show_states = (lines_geo) ->
    slines = lines.selectAll(".state_lines").data(lines_geo.features)

    slines.enter()
      .append("path")
      .attr("class", "state_lines")
      .attr("d", path)
      .attr("stroke", "#222")
      .attr("stroke-width", 2.3)
      .attr("fill", "none")


  update = () ->
    # add a radius to our data nodes that will serve to determine
    # when a collision has occurred. This uses the same scale as
    # the one used to size our bubbles, but it kicks up the minimum
    # size to make it so smaller bubbles have a slightly larger 
    # collision 'sphere'
    data.forEach (d,i) ->
      d.forceR = Math.max(minCollisionRadius, rScale(rValue(d)))

    # start up the force layout
    force.nodes(data).start()
    updateNodes()

  updateNodes = () ->
    # here we are using the idValue function to uniquely bind our
    # data to the (currently) empty 'bubble-node selection'.
    # if you want to use your own data, you just need to modify what
    # idValue returns
    node = node.selectAll(".bubble-node").data(data, (d) -> idValue(d))

    # we don't actually remove any nodes from our data in this example 
    # but if we did, this line of code would remove them from the
    # visualization as well
    node.exit().remove()

    # nodes are just links with circles inside.
    # the styling comes from the css
    node.enter()
     .append("a")
     .attr("class", "bubble-node")
     .attr("xlink:href", (d) -> "##{encodeURIComponent(idValue(d))}")
     .call(force.drag)
     .append("circle")
     .attr("r", (d) -> rScale(rValue(d)))
     .attr("fill", (d) -> colorScale(colorValue(d)))
     # .attr("r", 4)
     .attr("opacity", 0.7)

  # ---
  # custom gravity to skew the bubble placement
  # ---
  gravity = (alpha) ->
    # start with the center of the display
    cx = width / 2
    cy = height / 2
    # use alpha to affect how much to push
    # towards the horizontal or vertical
    ax = alpha / 8
    ay = alpha

    # return a function that will modify the
    # node's x and y values
    (d) ->
      d.x += (cx - d.x) * ax
      d.y += (cy - d.y) * ay

  location = (alpha) ->
    (d) ->
      d.x += (d.pos[0] - d.x) * alpha
      d.y += (d.pos[1] - d.y) * alpha

  # ---
  # custom collision function to prevent
  # nodes from touching
  # This version is brute force
  # we could use quadtree to speed up implementation
  # (which is what Mike's original version does)
  # ---
  collide = (jitter) ->
    # return a function that modifies
    # the x and y of a node
    (d) ->
      data.forEach (d2) ->
        # check that we aren't comparing a node
        # with itself
        if d != d2
          # use distance formula to find distance
          # between two nodes
          x = d.x - d2.x
          y = d.y - d2.y
          distance = Math.sqrt(x * x + y * y)
          # find current minimum space between two nodes
          # using the forceR that was set to match the 
          # visible radius of the nodes
          minDistance = d.forceR + d2.forceR + collisionPadding

          # if the current distance is less then the minimum
          # allowed then we need to push both nodes away from one another
          if distance < minDistance
            # scale the distance based on the jitter variable
            distance = (distance - minDistance) / distance * jitter
            # move our two nodes
            moveX = x * distance
            moveY = y * distance
            d.x -= moveX
            d.y -= moveY
            d2.x += moveX
            d2.y += moveY


  map.height = (_) ->
    if !arguments.length
      return height
    height = _
    map

  return map

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)


$ ->

  plot = BubbleMap()
  display = (data) ->
    plotData("#vis", data, plot)


  # d3.json("data/kansas_city_tracts_large_centroids.json", display)
  d3.json("data/kansas_city_tracts_large_centroids_with_ACS_10_5YR_S1902.json", display)

