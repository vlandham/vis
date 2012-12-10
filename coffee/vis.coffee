
root = exports ? this

Plot = () ->
  width = 200
  height = 160
  preview_width = 180
  preview_height = 140
  data = []
  points = null
  xScale = d3.scale.ordinal().rangeRoundBands([0,preview_width], 0.1)
  yScale = d3.scale.linear().range([0, preview_height])
  colorScale = d3.scale.ordinal()
    .range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c"])
  

  scaleFactor = 4

  chart = (selection) ->
    selection.each (rawData) ->

      data = rawData
      updateScales()

      svg = d3.select(this).select("#previews").selectAll("svg").data(data)
      svg.enter().append("svg")
      
      svg.attr("width", width)
      svg.attr("height", height)

      previews = svg.append("g")
        .attr("transform", "translate(#{(width/2) - preview_width/2},#{(height/2) - preview_height/2})")
        
    
      previews.each(drawGraph)

      previews.append("rect")
        .attr("width", preview_width)
        .attr("height", preview_height)
        .attr("fill", "none")
        .attr("class", "preview")
        .on("click", showDetail)

      d3.select("#detail").classed("hidden", true)
  
  drawGraph = (d,i) ->
    base = d3.select(this)
    base.append("rect")
      .attr("width", preview_width)
      .attr("height", preview_height)
      .attr("class", "background")

    graph = base.append("g")
    graph.selectAll(".bar")
      .data((d) -> d.values)
      .enter().append("rect")
      .attr("x", (d,i) -> xScale(d.name))
      .attr("y", (d) -> preview_height - yScale(d.value))
      .attr("width", xScale.rangeBand())
      .attr("height", (d,i) ->  yScale(d.value))
      .attr("fill", (d) -> colorScale(d.name))
      .on("mouseover", annotate)

    graph.append("text")
      .text((d) -> d.year)
      .attr("class", "title")
      .attr("text-anchor", "middle")
      .attr("x", preview_width / 2)
      .attr("dy", "1.3em")

  updateScales = () ->
    yMax = d3.max(data, (d) -> d3.max(d.values, (e) -> e.value))
    yScale.domain([0,yMax + 500000])
    # xMax = d3.max(data, (d) -> d.values.length)
    names = data[0].values.map (d) -> d.name
    xScale.domain(names)
    colorScale.domain(names)

  getPosition = (i) ->
    el = $('.preview')[i]
    pos = $(el).position()
    pos

  toggleHidden = (show) ->
    d3.select("#previews").classed("hidden", show).classed("visible", !show)
    d3.select("#detail").classed("hidden", !show).classed("visible", show)

  showDetail = (d,i) ->
    pos = getPosition(i)
    scrollTop = $(window).scrollTop()

    toggleHidden(true)
    
    console.log(d)
    top = d3.select("#detail_zoom")
    top.selectAll('.main').remove()
    g = top.selectAll('g').data([d]).enter()

    main = g.append("g")
      .attr("class", "main")

    # main.append("rect")
    #   .attr("width", preview_width)
    #   .attr("height", preview_height)
    #   .attr("class", "background")
    #   .on("click", (e,f) -> hideDetails(d,i))

    main.each(drawGraph)
    main.on("click", (e,f) -> hideDetails(d,i))
    
    main.attr('transform', 'translate(' + [pos.left, pos.top - scrollTop] + ')')
    main.transition().delay(500).duration(500).attr('transform', 'translate(' + [40, 0] + ') scale(' + scaleFactor + ')')

  hideDetails = (d,i) ->
    pos = getPosition(i)
    scrollTop = $(window).scrollTop()

    d3.selectAll('#detail_zoom .main').transition()
      .duration(500)
      .attr('transform', 'translate(' + [pos.left, pos.top - scrollTop] + ')')
      .each 'end', () ->
        toggleHidden(false)

  annotate = (d) ->
    console.log(d)

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

