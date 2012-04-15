
root = exports ? this


$ ->

  w = 450
  h = 105
  [pt, pr, pb, pl] = [80, 10, 10, 10]

  padding =
    A:0
    T:0
    G:10
    C:0

  data = null
  vis = null

  x_scale = d3.scale.linear()
    .domain([1, 6])
    .range([0, w])

  # x_scale = d3.scale.ordinal()
  #   .domain([1, 5])
  #   .rangePoints([0, w])

  y_scale = d3.scale.linear()
    .domain([1,4])
    .range([0, h])

  render_vis = (csv) ->
    data = [
      {col:1,row:1,base:"A",amount:1.0}
      {col:2,row:1,base:"T",amount:0.5}
      {col:2,row:2,base:"A",amount:0.5}
      {col:3,row:1,base:"G",amount:1.0}
      {col:4,row:1,base:"C",amount:0.3}
      {col:4,row:2,base:"A",amount:0.3}
      {col:4,row:3,base:"G",amount:0.4}
      {col:5,row:1,base:"T",amount:0.9}
    ]

    col_counts = {}

    data.forEach (d) ->
      col_counts[d.col] ?= 0
      col_counts[d.col] += 1

    console.log(col_counts)

    vis = d3.select("#vis")
      .append("svg")
      .attr("id", "vis-svg")
      .attr("width", w + (pl + pr))
      .attr("height", h + (pt + pb))

    view = vis.append("g")
      .attr("transform", "translate(#{pl},#{pt})")

    view.selectAll("path")
      .data(data)
    .enter().append("path")
      .attr("d", (d) -> helvetica[d.base])
      .attr("class", (d) -> d.base)
      .attr("transform", (d) ->
        # TODO: AWFUL - don't really do this
        y_scale.domain([1,col_counts[d.col] + 1])
        d.original_translation = "translate(#{x_scale(d.col) - padding[d.base]},#{h  - y_scale(d.row) - this.getBBox().height * d.amount})scale(1,#{d.amount})"
        d.original_translation
          
      )
      .on("mouseover", highlight)
      .on("mouseout", unhighlight)
      .on("click", move)


  highlight = (d) ->
    d3.select(this).classed("highlight", true)

  unhighlight = (d) ->
    d3.select(this).classed("highlight", false)

  move = (d) ->
    element = d3.select(this)
    element.transition()
      .duration(1000)
    .attr("transform", (d) -> "#{d.original_translation}rotate(-90)")

    element.transition()
      .duration(1000)
      .delay(1000)
    .attr("transform", (d) -> d.original_translation)
      



  d3.csv "data/test.csv", render_vis
