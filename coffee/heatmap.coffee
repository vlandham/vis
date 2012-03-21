root = exports ? this

heatmapChart = () ->
  margin = {top: 20, right: 20, bottom: 20, left: 20}
  width = 800
  height = 800
  xValue = (d) -> d.x
  yValue = (d) -> d.y
  zValue = (d) -> parseInt(d.z)

  xScale = d3.scale.ordinal().rangeBands([0, width])
  yScale = d3.scale.ordinal().rangeBands([0, height])
  zScale = d3.scale.linear().range(['blue','red'])
  onClick = (d,i) -> console.log(d)

  chart = (selection) ->
    selection.each (data) ->
      data = data.map (d, i) ->
        [xValue.call(data, d, i), yValue.call(data, d, i), zValue.call(data, d, i)]

      console.log(data)
      xScale.domain(data.map (d) -> d[0])
      yScale.domain(data.map (d) -> d[1])
      zScale.domain(d3.extent(data, (d) -> d[2]))
      
      # select svg if it exists
      svg = d3.select(this).selectAll("svg").data([data])

      # otherwise, create skeletal structure for heatmap
      gEnter = svg.enter().append("svg").append("g")

      svg.attr("width", width)
      svg.attr("height", height)

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
        .attr("transform", (d,i) -> "translate(#{0},#{yScale(d[1])})")
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
        .text((d,i) -> d[1])

      column = g.selectAll(".column")
        .data(data)
      .enter().append("g")
        .attr("class", "column")
        .attr("transform", (d, i) -> "translate(#{xScale(d[0])}) rotate(#{-90})")

      column.append("text")
        .attr("x", 6)
        .attr("y", xScale.rangeBand() / 2)
        .attr("dy", ".32em")
        .attr("text-anchor", "start")
        .text( (d,i) -> d[0])

      column.append("line")
        .attr("x1", -width)
        .attr("class", "col_line")


  buildRow = (row) ->
    cell = d3.select(this).selectAll(".cell")
      .data([row])
    .enter().append("rect")
      .attr("class", "cell")
      .attr("x", (d) -> xScale(d[0]))
      .attr("width", xScale.rangeBand())
      .attr("height", xScale.rangeBand())
      .attr("fill", (d) -> zScale(d[2]))
      .on("mouseover", mouseover)
      .on("mouseout", mouseout)
      .on("click", onClick)

  mouseover = (d,i) ->
    console.log(d3.event)

  mouseout = (d,i) ->
    console.log(d)

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

  chart.margin = (_) ->
    if !arguments.length
      return margin
    margin = _
    chart

  return chart

root.heatmapChart = heatmapChart

