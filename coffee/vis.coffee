
root = exports ? this

Plot = () ->
  width = 200
  height = 200
  data = []
  points = null
  margin = {top: 0, right: 0, bottom: 0, left: 0}
  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([0,height])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)

  chart = (selection) ->
    selection.each (rawData) ->

      data = rawData

      svg = d3.select(this).selectAll("#previews .preview svg").data(data)
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")


      g.append("rect").attr("width", width / 2).attr("height", height / 2).attr("fill", "steelblue")
        .attr("class", "preview")
        .attr("transform", "translate(#{width/2},#{height/2})")
        .on("click", focus)

  focus = (d,i) ->
    pos = getPosition(i)
    scrollTop = $(window).scrollTop()
    console.log(pos)

  getPosition = (i) ->
    el = $('.preview')[i]
    pos = $(el).position()
    pos

  showDetail = (d,i) ->
    svg = d3.selectAll('#detail svg')
    g = svg.selectAll('#full')



      # points = g.append("g").attr("id", "vis_points")
  #     update()

  # update = () ->
  #   points.selectAll(".point")
  #     .data(data).enter()
  #     .append("circle")
  #     .attr("cx", (d) -> xScale(xValue(d)))
  #     .attr("cy", (d) -> yScale(yValue(d)))
  #     .attr("r", 4)
  #     .attr("fill", "steelblue")

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
  display = (data) ->
    plotData("#vis", data, plot)


  d3.csv("data/test.csv", display)

