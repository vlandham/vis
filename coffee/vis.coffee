
root = exports ? this

Plot = () ->
  width = 900
  height = 600
  data = []
  points = null
  margin = {top: 20, right: 20, bottom: 20, left: 20}
  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([0,height])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)
  color = d3.scale.linear()
    .domain([9,50])
    .range(['steelblue', 'brown'])
    .interpolate(d3.interpolateLab)

  prepareData = (data) ->
    # data = data.filter (d) -> true
    data.forEach (d) ->
      d3.keys(d).forEach (k) ->
        d[k] = parseInt(d[k])

    data

  chart = (selection) ->
    selection.each (rawData) ->

      data = prepareData(rawData)
      console.log(data)
      pcs = d3.parcoords()("#vis")
        .data(data)
        .alpha(0.4)
        .color("#000")
        .margin({ top: 24, left: 10, bottom: 12, right: 10 })
        .mode("queue")
        .render()
        .brushable()
        # .reorderable()


      # svg = d3.select(this).selectAll("svg").data([data])
      # gEnter = svg.enter().append("svg").append("g")
      
      # svg.attr("width", width + margin.left + margin.right )
      # svg.attr("height", height + margin.top + margin.bottom )

      # g = svg.select("g")
        # .attr("transform", "translate(#{margin.left},#{margin.top})")

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
    .defer(d3.csv, "data/all2.csv")
    .await(display)

