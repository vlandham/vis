
root = exports ? this

$ ->

  w = 300
  h = 300
  r = 3
  [pt, pr, pb, pl] = [20, 20, 20, 20]

  data = null
  vis = null

  x_scale = d3.scale.linear()
    .domain([0, 90])
    .range([0, w])

  # projection = (d) ->
  #   r = d.y
  #   a = (d.x - 90) / 180 * Math.PI
  #   [r * Math.cos(a), r * Math.sin(a)]

  # if w == h, then the radius can be w
  # else, some fraction of w is needed
  max_circle_radius = w

  radial_projection = (d, r = max_circle_radius) ->
    a = (d.x - 90) / 180 * Math.PI
    out = [r * Math.cos(a), h + r * Math.sin(a)]
    out

  # helpers to get just x / y
  radial_x = (d, r = max_circle_radius) ->
    radial_projection(d,r)[0]

  radial_y = (d, r = max_circle_radius) ->
    radial_projection(d,r)[1]

  # function that creates visualization
  # called below on data load
  render_vis = (csv) ->
    data = csv

    vis = d3.select("#vis")
      .append("svg")
      .attr("id", "vis-svg")
      .attr("width", w + (pl + pr))
      .attr("height", h + (pt + pb))

    # background grey rect
    vis.append("rect")
      .attr("width", w + (pl + pr))
      .attr("height", h + (pt + pb))
      .attr("fill", "#eee")
      .attr("pointer-events","all")

    # x-axis
    vis.append("line")
      .attr("x1", 0)
      .attr("x2", w)
      .attr("y1", h)
      .attr("y2", h)
      .attr("stroke", "#222")
      .attr("transform", "translate(#{pr},#{pt})")

    # y-axis
    vis.append("line")
      .attr("x1", 0)
      .attr("x2", 0)
      .attr("y1", 0)
      .attr("y2", h)
      .attr("stroke", "#222")
      .attr("transform", "translate(#{pr},#{pt})")

    # group containing all points
    points_g = vis.append("g")
      .attr("transform", "translate(#{pr}, #{pb})")


    # group for each line of points
    points = points_g.selectAll(".points")
      .data(data)
    .enter().append("g")
      .attr("class", "points")

    # create circles for each point
    points.each (d) ->
      # y is used as count
      # create an array of counts
      num_points = (num for num in [1..d.y])
      # create data points incorporating this count
      point_data = num_points.map (e) -> {x: d.x, count: e}
      # create new point from point_data
      # positioning code could be its own function
      d3.select(this).selectAll(".point")
        .data(point_data)
      .enter().append("circle")
        .attr("cx", (d) -> radial_x(d, max_circle_radius - (d.count * r*2)))
        .attr("cy", (d) -> radial_y(d, max_circle_radius - (d.count * r*2)))
        .attr("r", (d) -> r)
        .attr("fill", "#4e4e4e")

    # group to store tick lines
    lines_g = vis.append("g")
      .attr("transform", "translate(#{pr}, #{pb})")

    # experiment to create a line for each
    # data point
    # Not useful
    lines = lines_g.selectAll(".line")
      .data(data)
    .enter().append("line")
      .attr("x1", 0)
      .attr("x2", (d) -> radial_x(d))
      .attr("y1", h)
      .attr("y2", (d) -> radial_y(d))
      .attr("stroke", "#eee")
      .attr("stroke-width", 0)

    # reuse lines_g / lines variables
    lines_g = vis.append("g")
      .attr("transform", "translate(#{pr}, #{pb})")

    # tick lines using x_scale.
    # x_scale isn't really tied to the data
    # could just generate tick scale here
    # and remove x_scale
    lines = lines_g.selectAll(".line")
      .data(x_scale.ticks(10))
    .enter().append("line")
      .attr("x1", 0)
      .attr("x2", (d) -> radial_x({x:d}))
      .attr("y1", h)
      .attr("y2", (d) -> radial_y({x:d}))
      .attr("stroke", "#333")
      .attr("stroke-width", 0)

  # load csv and call render_vis
  d3.csv "data/test.csv", render_vis
