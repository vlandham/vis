
root = exports ? this

Plot = () ->
  width = 200
  height = 200
  preview_width = 180
  preview_height = 140
  data = []
  points = null
  xScale = d3.scale.ordinal().rangeRoundBands([0,preview_width], 0.1)
  yScale = d3.scale.linear().range([0, preview_height])
  colorScale = d3.scale.ordinal()
    .range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c"])
  

  scaleFactor = 3

  chart = (selection) ->
    selection.each (rawData) ->

      data = rawData

      updateScales()

      svg = d3.select(this).select("#previews").selectAll("svg").data(data)
      svg.enter().append("svg").append("g")
      
      svg.attr("width", width)
      svg.attr("height", height)

      previews = svg.append("g")
        .attr("transform", "translate(#{(width/2) - preview_width/2},#{(height/2) - preview_height/2})")
        
    
      previews.append("rect")
        .attr("width", preview_width)
        .attr("height", preview_height)
        .attr("fill", "#d3d3d3")
        .attr("class", "preview")
        .on("click", showDetail)

      previews.append("g").each(drawPreview)

      d3.select("#detail").classed("hidden", true)
  
  drawPreview = (d,i) ->
    d3.select(this).selectAll(".bar")
      .data((d) -> d.values)
      .enter().append("rect")
      .attr("x", (d,i) -> xScale(d.name))
      .attr("y", (d) -> preview_height - yScale(d.value))
      .attr("width", xScale.rangeBand())
      .attr("height", (d,i) ->  yScale(d.value))
      .attr("fill", (d) -> colorScale(d.name))

  updateScales = () ->
    yMax = d3.max(data, (d) -> d3.max(d.values, (e) -> e.value))
    yScale.domain([0,yMax])
    # xMax = d3.max(data, (d) -> d.values.length)
    names = data[0].values.map (d) -> d.name
    xScale.domain(names)
    colorScale.domain(names)

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


  chart.width = (_) ->
    if !arguments.length
      return width
    width = _
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


  d3.json("data/co2_kt_data.json", display)

