
class BubbleChart
  constructor: (data) ->
    @data = data
    @width = 940
    @height = 600

    @center = {x: @width / 2, y: @height / 2}
    @year_centers = {
      "2008": {x: @width / 3, y: @height / 2},
      "2009": {x: @width / 2, y: @height / 2},
      "2010": {x: 2 * @width / 3, y: @height / 2}
    }

    @vis = null
    @nodes = []
    @gravity = 0.1
    @force = null
    @circles = null
    @fill_color = d3.scale.ordinal()
      .domain(["low", "medium", "high"])
      .range(["#d84b2a", "#beccae", "#7aa25c"])

    max_amount = d3.max(@data, (d) -> d.total_amount)
    @radius_scale = d3.scale.pow().exponent(0.5).domain([0, max_amount]).range([1, 10])
    
    this.create_nodes()
    this.create_vis()

  # create node objects from original data
  # that will serve as the data behind each
  # bubble in the vis, then add each node
  # to @nodes to be used later
  create_nodes: () =>
    @data.forEach (d) =>
      node = {
        id: d.id
        radius: @radius_scale(d.total_amount)
        value: d.total_amount
        name: d.grant_title
        org: d.organization
        group: d.group
        year: d.start_year
        x: Math.random() * 1000
        y: Math.random() * 900
      }
      @nodes.push node

    @nodes.sort (a,b) -> b.value - a.value


  # create svg at #vis and then 
  # create circle representation for each node
  create_vis: () =>
    @vis = d3.select("#vis").append("svg")
      .attr("width", @width)
      .attr("height", @height)
      .attr("id", "svg_vis")

    @circles = @vis.selectAll("circle")
      .data(@nodes, (d) -> d.id)

    # radius will be set to 0 initially.
    @circles.enter().append("circle")
      .attr("r", 0)
      .attr("fill", (d) => @fill_color(d.group))
      .attr("stroke-width", 2)
      .attr("stroke", (d) => d3.rgb(@fill_color(d.group)).darker())
      .attr("id", (d) -> "bubble_#{d.id}")

    @circles.transition().duration(2000).attr("r", (d) -> d.radius)

  charge: (d) ->
    if (d.value < 0)
      0
    else
      -Math.pow(d.radius, 2.0) / 8

  start: () =>
    @force = d3.layout.force()
      .nodes(@nodes)
      .size([@width, @height])

  display_group_all: () =>
    @force.gravity(-0.01)
      .charge(this.charge)
      .friction(0.9)
      .on "tick", (e) =>
        @circles.each(this.move_towards_center(e.alpha))
          .attr("cx", (d) -> d.x)
          .attr("cy", (d) -> d.y)
    @force.start()

  # moves all circles towards the @center
  # of the visualization
  move_towards_center: (alpha) =>
    (d) =>
      d.x = d.x + (@center.x - d.x) * (@gravity + 0.02) * alpha
      d.y = d.y + (@center.y - d.y) * (@gravity + 0.02) * alpha

  display_by_year: () =>
    @force.gravity(-0.01)
      .charge(this.charge)
      .friction(0.9)
      .on "tick", (e) =>
        @circles.each(this.move_towards_year(e.alpha))
          .attr("cx", (d) -> d.x)
          .attr("cy", (d) -> d.y)
    @force.start()

  # move all circles to their associated @year_centers 
  move_towards_year: (alpha) =>
    (d) =>
      target = @year_centers[d.year]
      d.x = d.x + (target.x - d.x) * (@gravity + 0.02) * alpha * 1.1
      d.y = d.y + (target.y - d.y) * (@gravity + 0.02) * alpha * 1.1

root = exports ? this

$ ->
  chart = null

  render_vis = (csv) ->
    chart = new BubbleChart csv
    chart.start()
    root.display_all()
  root.display_all = () =>
    chart.display_group_all()
  root.display_year = () =>
    chart.display_by_year()
  root.toggle_view = (view_type) =>
    if view_type == 'year'
      root.display_year()
    else
      root.display_all()

  d3.csv "data/gates_money.csv", render_vis
