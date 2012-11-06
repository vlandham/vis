
root = exports ? this

Plot = () ->
  width = 200
  height = 200
  preview_width = 100
  preview_height = 100
  data = []
  points = null
  margin = {top: 0, right: 0, bottom: 0, left: 0}
  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([0,height])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)

  scaleFactor = 3

  chart = (selection) ->
    selection.each (rawData) ->

      data = rawData

      svg = d3.select(this).select("#previews").selectAll("svg").data(data)
      svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")
    
      g.append("rect")
        .attr("width", preview_width)
        .attr("height", preview_height)
        .attr("fill", "steelblue")
        .attr("class", "preview")
        .attr("transform", "translate(#{(width/2) - preview_width/2},#{(height/2) - preview_height/2})")
        .on("click", showDetail)

      d3.select("#detail").classed("hidden", true)

  getPosition = (i) ->
    el = $('.preview')[i]
    pos = $(el).position()
    pos

  toggleDetail = (show) ->
    d3.select("#previews").classed("hidden", show).classed("visible", !show)
    d3.select("#detail").classed("hidden", !show).classed("visible", show)

  showDetail = (d,i) ->
    pos = getPosition(i)
    scrollTop = $(window).scrollTop()

    toggleDetail(true)

    g = d3.selectAll('#detail_zoom')
    g.append("rect")
      .attr("width", preview_width)
      .attr("height", preview_height)
      .attr("fill", "steelblue")
      .on("click", (e,f) -> hideDetails(d,i))

    g.attr('transform', 'translate(' + [pos.left, pos.top - scrollTop] + ')')
    g.transition().delay(500).duration(500).attr('transform', 'translate(' + [0, 20] + ') scale(' + scaleFactor + ')')

  hideDetails = (d,i) ->
    pos = getPosition(i)
    scrollTop = $(window).scrollTop()

    d3.selectAll('#detail_zoom').transition()
      .duration(500)
      .attr('transform', 'translate(' + [pos.left, pos.top - scrollTop] + ')')
      .each 'end', () ->
        toggleDetail(false)


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

