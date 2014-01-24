
root = exports ? this

Plot = () ->
  width = 600
  height = 600
  data = []
  path = null
  toggle = false
  margin = {top: 20, right: 20, bottom: 20, left: 20}
  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([0,height])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)

  animate = () ->
    path.filter((d,i) -> Math.random() < 0.2).transition()
      .duration(1000)
      .attr "fill", (d) ->
        toggle = !toggle
        if toggle
          fill = d3.select(this).attr("ofill")
        else
          fill = "white"
        fill
          


    # if toggle
    #   path.filter((d,i) -> Math.random() < 0.3).transition()
    #     .duration(1000)
    #     .attr("fill", "white")
    # else
    #   path.transition()
    #     .duration(1000)
    #     .attr "fill", (d) -> 
    #       fill = d3.select(this).attr("ofill")
    #       fill

  chart = (selection) ->
    selection.each (rawData) ->

      d3.select(this).node().appendChild(rawData.documentElement)
      svg = d3.select("svg")

      path = d3.selectAll("path").filter (d) -> d3.select(this).attr("fill-rule") == "evenodd"
      path.each (d) ->
        fill = d3.select(this).attr("fill")
        d3.select(this).attr("ofill", fill)
        console.log(fill)
      intervalId = window.setInterval(animate, 500)
      console.log(path)


      # data = rawData

      # svg = d3.select(this).selectAll("svg").data([data])
      # gEnter = svg.enter().append("svg").append("g")
      # 
      # svg.attr("width", width + margin.left + margin.right )
      # svg.attr("height", height + margin.top + margin.bottom )

      # g = svg.select("g")
      #   .attr("transform", "translate(#{margin.left},#{margin.top})")

      # points = g.append("g").attr("id", "vis_points")
      # update()

  update = () ->
    points.selectAll(".point")
      .data(data).enter()
      .append("circle")
      .attr("cx", (d) -> xScale(xValue(d)))
      .attr("cy", (d) -> yScale(yValue(d)))
      .attr("r", 4)
      .attr("fill", "steelblue")

  chart.height = (_) ->
    if !arguments.length
      return height
    height = _
    chart

  chart.width = (_) ->
    if !arguments.length
      return width
    width = _
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

  return chart

root.Plot = Plot

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)


$ ->

  plot = Plot()
  display = (error, data) ->
    plotData("#vis", data, plot)

  queue()
    .defer(d3.xml, "data/logo.svg")
    .await(display)

