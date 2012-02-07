
root = exports ? this

$ ->

  w = 940
  h = 600
  r = 3
  [pt, pr, pb, pl] = [10, 10, 10, 10]

  data = null
  vis = null

  x_scale = d3.scale.linear()
    .domain([0, 10])
    .range([0, w])

  y_scale = d3.scale.linear()
    .domain([0, 10])
    .range([0, h])

  render_vis = (csv) ->
    data = csv
    console.log(data)

    vis = d3.select("#vis")
      .append("svg")
      .attr("id", "vis-svg")
      .attr("width", w + (pl + pr))
      .attr("height", h + (pt + pb))

    vis.append("rect")
      .attr("width", w + (pl + pr))
      .attr("height", h + (pt + pb))
      .attr("fill", "#ddd")
      .attr("pointer-events","all")

    points_g = vis.append("g")
      .attr("transform", "translate(#{pr},#{pt}")


    points = points_g.selectAll(".point")
      .data(data)
    .enter().append("circle")
      .attr("cx", (d) -> x_scale(d.x))
      .attr("cy", (d) -> y_scale(d.y))
      .attr("r", r)
      .attr("fill", "#4e4e4e")


  d3.csv "data/test.csv", render_vis
