root = exports ? this

heatmapChart = () ->
  margin = {top: 20, right: 20, bottom: 20, left: 20}
  width = 800
  height = 800
  transition_time = 800
  xValue = (d) -> d.x
  yValue = (d) -> d.y
  zValue = (d) -> parseFloat(d.z)

  xScale = d3.scale.ordinal().rangeBands([0, width])
  yScale = d3.scale.ordinal().rangeBands([0, height])
  zScale = d3.scale.linear().range(['#C6DBEF','#08306B'])
  svg = null
  orders = {x:null,y:null}
  onClick = (d,i) -> console.log(d)

  chart = (selection) ->
    selection.each (data) ->
      data = data.map (d, i) ->
        new_data = d
        new_data.x = xValue.call(data, d, i)
        new_data.y = yValue.call(data, d, i)
        new_data.z = zValue.call(data, d, i)
        new_data

      data_counts = {}
      data.forEach (d) ->
        data_counts[d.x] ?= {}
        data_counts[d.x][d.y] ?= 0
        data_counts[d.x][d.y] += 1

      console.log(data_counts)

      unique_x_names = d3.keys(data_counts)

      unique_y_names = {}
      d3.entries(data_counts).forEach (e) ->
        d3.keys(e.value).forEach (k) ->
          unique_y_names[k] ?= 1

      unique_y_names = d3.keys(unique_y_names)

      console.log(unique_y_names)

      orders =
        x:
          original: data.map((d) -> d.x)
          name_asc: data.map((d) -> d.x).sort((a,b) -> d3.ascending(a,b))
          name_dsc: data.map((d) -> d.x).sort((a,b) -> d3.descending(a,b))
        y:
          original: data.map((d) -> d.y)
          name_asc: data.map((d) -> d.y).sort((a,b) -> d3.ascending(a,b))
          name_dsc: data.map((d) -> d.y).sort((a,b) -> d3.descending(a,b))

      xScale.domain(orders.x.original)
      yScale.domain(orders.y.original)

      zScale.domain(d3.extent(data, (d) -> d.z))
      
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

      row_text = g.selectAll("row_text")
        .data(unique_y_names)
      .enter().append("g")
        .attr("class", "row_text")
        .attr("transform", (d,i) -> "translate(#{0},#{yScale(d)})")

      row_text.append("line")
        .attr("x1", 0)
        .attr("x2", width)
        .attr("class", "row_line")

      row_text.append("text")
        .attr("x", -6)
        .attr("y", yScale.rangeBand() / 2)
        .attr("dy", ".32em")
        .attr("text-anchor", "end")
        .text((d,i) -> d)

      # row.append("line")
      #   .attr("x1", 0)
      #   .attr("x2", width)
      #   .attr("class", "row_line")

      # row.append("text")
      #   .attr("x", -6)
      #   .attr("y", yScale.rangeBand() / 2)
      #   .attr("dy", ".32em")
      #   .attr("text-anchor", "end")
      #   .text((d,i) -> d.y)

      console.log(unique_x_names)
      console.log(xScale(unique_x_names[1]))

      column = g.selectAll(".column")
        .data(unique_x_names)
      .enter().append("g")
        .attr("class", "column")
        .attr("transform", (d, i) -> "translate(#{xScale(d)}) rotate(#{-90})")

      column.append("text")
        .attr("x", 6)
        .attr("y", xScale.rangeBand() / 2)
        .attr("dy", ".32em")
        .attr("text-anchor", "start")
        .text( (d,i) -> d)

      column.append("line")
        .attr("x1", -width)
        .attr("class", "col_line")

      # timeout = setTimeout = () ->
        # order("group")
        # d3.select("#order_row").property("selectedIndex", 2).node().focus()

      d3.select("#order_row").on "change", () ->
        # clearTimeout(timeout)
        chart.order("y",this.value)

      d3.select("#order_col").on "change", () ->
        # clearTimeout(timeout)
        chart.order("x",this.value)

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
    d3.selectAll(".row_text text").classed("active", (d, i) -> d == p.y)
    d3.selectAll(".column text").classed("active", (d, i) -> d == p.x)

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

  # TODO: trying to make this work for both x and y 
  # however needs some work
  chart.order = (axis, value) ->
    scale = if axis == "x" then xScale else yScale
    scale.domain(orders[axis][value])

    # console.log(xScale.domain())

    t = svg.transition().duration(transition_time)

    delay = 2.5

    t.selectAll(".row")
        .delay( (d,i) -> yScale(d.y) * delay)
        .attr("transform", (d,i) -> "translate(0,#{yScale(d.y)})")
      .selectAll(".cell")
        .delay((d) -> xScale(d.x) * delay)
        .attr("x", (d) -> xScale(d.x))

    t.selectAll(".row_text")
        .delay((d,i) -> yScale(d) * delay)
        .attr("transform", (d,i) -> "translate(0,#{yScale(d)})")

    t.selectAll(".column")
        .delay((d,i) -> xScale(d) * delay)
        .attr("transform", (d,i) -> "translate(#{xScale(d)})rotate(-90)")


  return chart

root.heatmapChart = heatmapChart

