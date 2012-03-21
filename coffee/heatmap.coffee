root = exports ? this

heatmapChart = () ->
  margin = {top: 20, right: 20, bottom: 20, left: 20}
  width = 800
  height = 800
  xValue = (d) -> d.x
  yValue = (d) -> d.y
  zValue = (d) -> parseFloat(d.z)

  xScale = d3.scale.ordinal().rangeBands([0, width])
  yScale = d3.scale.ordinal().rangeBands([0, height])
  zScale = d3.scale.linear().range(['#C6DBEF','#08306B'])
  onClick = (d,i) -> console.log(d)

  chart = (selection) ->
    selection.each (data) ->
      data = data.map (d, i) ->
        new_data = d
        new_data.x = xValue.call(data, d, i)
        new_data.y = yValue.call(data, d, i)
        new_data.z = zValue.call(data, d, i)
        new_data

      console.log(data)
      xScale.domain(data.map (d) -> d.x)
      yScale.domain(data.map (d) -> d.y)
      zScale.domain(d3.extent(data, (d) -> d.z))

      console.log(data)
      
      # select svg if it exists
      svg = d3.select(this).selectAll("svg").data([data])


      # otherwise, create skeletal structure for heatmap
      gEnter = svg.enter().append("svg").append("g")

      svg.attr("width", width + margin.left + margin.right)
      svg.attr("height", height + margin.top + margin.bottom)


      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      g.append("rect")
        .attr("class", "background")
        .attr("width", width)
        .attr("height", height)

      row = g.selectAll(".row")
        .data(data)
      .enter().append("g")
        .attr("class", "row")
        .attr("transform", (d,i) -> "translate(#{0},#{yScale(d.y)})")
        .each(buildRow)

      row.append("line")
        .attr("x1", 0)
        .attr("x2", width)
        .attr("class", "row_line")

      row.append("text")
        .attr("x", -6)
        .attr("y", yScale.rangeBand() / 2)
        .attr("dy", ".32em")
        .attr("text-anchor", "end")
        .text((d,i) -> d.y)

      column = g.selectAll(".column")
        .data(data)
      .enter().append("g")
        .attr("class", "column")
        .attr("transform", (d, i) -> "translate(#{xScale(d.x)}) rotate(#{-90})")

      column.append("text")
        .attr("x", 6)
        .attr("y", xScale.rangeBand() / 2)
        .attr("dy", ".32em")
        .attr("text-anchor", "start")
        .text( (d,i) -> d.x)

      column.append("line")
        .attr("x1", -width)
        .attr("class", "col_line")


  buildRow = (row) ->
    cell = d3.select(this).selectAll(".cell")
      .data([row])
    .enter().append("rect")
      .attr("class", "cell")
      .attr("x", (d) -> xScale(d.x))
      .attr("width", xScale.rangeBand())
      .attr("height", yScale.rangeBand())
      .attr("fill", (d) -> zScale(d.z))
      .on("mouseover", mouseover)
      .on("mouseout", mouseout)
      .on("click", onClick)

  mouseover = (p,i) ->
    d3.selectAll(".row text").classed("active", (d, i) -> d.y == p.y)
    d3.selectAll(".column text").classed("active", (d, i) -> d.x == p.x)

  mouseout = (p,i) ->
    d3.selectAll("text").classed("active", false)

  chart.width = (_) ->
    if !arguments.length
      return width
    width = _
    chart

  chart.height = (_) ->
    if !arguments.length
      return height
    height = _
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

  chart.z = (_) ->
    if !arguments.length
      return zValue
    zValue = _
    chart

  chart.scale = (_) ->
    if !arguments.length
      return zScale
    zScale = _
    chart

  return chart

root.heatmapChart = heatmapChart

