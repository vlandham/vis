# ---
# General helper functions
# to assist with formatting numbers
# ---
addCommas = (number) ->
  number += ''
  values = number.split('.')
  num = values[0]
  dec = if values.length > 1 then '.' + values[1] else ''
  rgx = /(\d+)(\d{3})/
  while rgx.test(num)
    num = num.replace(rgx, '$1' + ',' + '$2')
  num + dec

roundNumber = (number, decimals) ->
  Math.round(number * Math.pow(10, decimals)) / Math.pow(10, decimals)

formatNumber = (number) ->
  addCommas(roundNumber(number,0))

# ---
# Using the 'reusable charts' style closure for 
# encapsulating the visualization code
# ---
SmallMults = () ->
  # ---
  # Variables availible to all of SmallMults
  # ---
  
  # size of the svg's that hold the small multiples 
  width = 200
  height = 160
  # size of the drawing area inside the svg's to make
  # the bar charts
  graphWidth = 180
  graphHeight = 140
  # padding used underneath the bars to make space
  # for the names of the countries
  yPadding = 12
  # placeholder for the data
  data = []

  # using an ordinal scale for X as our
  # data is categorical (the names of countries)
  xScale = d3.scale.ordinal()
    .rangeRoundBands([0, graphWidth], 0.1)

  # names will also be used to color the bars
  colorScale = d3.scale.ordinal()
    .range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c"])

  # yPadding is removed to make room for country names
  yScale = d3.scale.linear()
    .range([0, graphHeight - yPadding])

  # This is the amount by which we will enlarge the small chart 
  # when displaying it in detail display
  scaleFactor = 4

  # handy dandy tooltip for detail display
  tooltip = Tooltip("vis-tooltip", 230)
 
  # ---
  # Main entry point for our visualization.
  # SVG elements for each small chart are created
  # as well as graph inside each SVG.
  # ---
  chart = (selection) ->
    selection.each (rawData) ->
      # store our data and set the scale domains
      data = rawData
      setScales()

      # bind data to svg elements so there will be a svg for
      # each year
      pre = d3.select(this).select("#previews")
        .selectAll(".preview").data(data)

      # create the svg elements
      pre.enter()
        .append("div")
        .attr("class", "preview")
        .attr("width", width)
        .attr("height", height)

      svgs = pre.append("svg")
        .attr("width", width)
        .attr("height", height)

      # create a group for displaying the barchart in
      previews = svgs.append("g")
       
      # draw the graphs for each data element.
      # This will call 'drawGraph' for each element
      # of the data and will pass in the data as well
      # as the associated group element where the 
      # chart is to be drawn
      previews.each(drawGraph)

      # create a rect overlay that will intercept
      # mouse clicks and show detail view of clicked
      # graph
      previews.append("rect")
        .attr("width", graphWidth)
        .attr("height", graphHeight)
        .attr("class", "mouse_preview")
        .on("click", showDetail)

  # ---
  # Code for drawing a barchart
  # ---
  drawGraph = (d,i) ->
    # the 'this' element is the group
    # element which the barchart will
    # live in
    base = d3.select(this)
    base.append("rect")
      .attr("width", graphWidth)
      .attr("height", graphHeight)
      .attr("class", "background")

    # create the bars
    graph = base.append("g")
    graph.selectAll(".bar")
      .data((d) -> d.values)
      .enter().append("rect")
      .attr("x", (d,i) -> xScale(d.name))
      .attr("y", (d) -> (graphHeight - yScale(d.value) - yPadding))
      .attr("width", xScale.rangeBand())
      .attr("height", (d,i) ->  yScale(d.value))
      .attr("fill", (d) -> colorScale(d.name))
      .on("mouseover", showTooltip)
      .on("mouseout", hideTooltip)

    # add the year title
    graph.append("text")
      .text((d) -> d.year)
      .attr("class", "title")
      .attr("text-anchor", "middle")
      .attr("x", graphWidth / 2)
      .attr("dy", "1.3em")

  # ---
  # This creates the additional text displayed for
  # the detail view.
  # ---
  drawDetails = (d,i) ->
    # like in 'drawGraph', 'this'
    # is the group element to draw
    # the details in
    graph = d3.select(this)

    # add names under the bars
    graph.selectAll(".name").data(d.values).enter()
      .append("text")
      .attr("class", "name")
      .text((d) -> d.name)
      .attr("text-anchor", "middle")
      .attr("y", graphHeight - yPadding)
      .attr("dy", "1.3em")
      .attr("x", (d,i) -> xScale(d.name) + xScale.rangeBand() / 2)
      .attr("font-size", 8)

  # ---
  # Shows the detail view for a given element
  # This works by appending a copy of the graph
  # to the 'detail' svg while switching the
  # detail section to visible
  # ---
  showDetail = (d,i) ->
    # switch the css on which divs are hidden
    toggleHidden(true)
    
    detail_view = d3.select("#detail_view")

    # clear any existing detail view
    detail_view.selectAll('.main').remove()

    # bind the single element to be detailed to the 
    # detail view's group
    detail_g = detail_view.selectAll('g').data([d]).enter()

    # create a new group to display the graph in
    main = detail_g.append("g")
      .attr("class", "main")

    # draw graph just like in the initial creation
    # of the small multiples
    main.each(drawGraph)

    # add details specific to the detail view
    main.each(drawDetails)

    # setup click handler to hide detail view once
    # graph or detail panel is clicked
    main.on("click", () -> hideDetail(d,i))
    d3.select("#detail").on("click", () -> hideDetail(d,i))
   
    # Here is the code responsible for the lovely zoom
    # affect of the detail view
    
    # getPosition is a helper function to
    # return the relative location of the graph
    # to be viewed in the detail view
    pos = getPosition(i)
    # scrollTop returns the number of pixels
    # hidden on the top of the window because of
    # the window being scrolled down
    # http://api.jquery.com/scrollTop/
    scrollTop = $(window).scrollTop()

    # first we move our (small) detail graph to be positioned over
    # its preview version
    main.attr('transform', "translate(#{pos.left},#{pos.top - scrollTop})")
    # then we use a transition to center the detailed graph and scale it
    # up to be bigger
    main.transition()
      .delay(500)
      .duration(500)
      .attr('transform', "translate(#{40},#{0}) scale(#{scaleFactor})")

  # ---
  # This function shrinks the detail view back from whence it came
  # ---
  hideDetail = (d,i) ->
    # hide the tooltip if present
    hideTooltip(d,i)
    # see showDetail for... details
    pos = getPosition(i)
    scrollTop = $(window).scrollTop()

    # Use transition to move the detail panel back 
    # down to its preview's location
    # The view also shrinks back to its preview size
    # because d3's transition can tween between the 
    # scale it had, and the lack of scale here.
    d3.selectAll('#detail_view .main').transition()
      .duration(500)
      .attr('transform', "translate(#{pos.left},#{pos.top - scrollTop})")
      .each 'end', () ->
        toggleHidden(false)

  # ---
  # Toggles hidden css between the previews and detail view divs
  # if show is true, the detail view is shown.
  # ---
  toggleHidden = (show) ->
    d3.select("#previews").classed("hidden", show).classed("visible", !show)
    d3.select("#detail").classed("hidden", !show).classed("visible", show)

  # ---
  # Display content in tooltip on mouseover of bars
  # ---
  showTooltip = (d) ->
    content = '<p class="main">' + d.name + '</p>'
    content += '<hr class="tooltip-hr">'
    content += '<span class="name">CO2 Emissons: </span><span class="value">' + formatNumber(d.value) + ' kt</span><br/>'
    content += '<span class="name">Worldwide Emissions: </span><span class="value">' + formatNumber(d.percent_world * 100) + '%</span><br/>'
    tooltip.showTooltip(content,d3.event)

  # ---
  # Hide tooltip
  # ---
  hideTooltip = (d,i) ->
    tooltip.hideTooltip()

  # ---
  # Updates domains for scales used in bar charts
  # expects 'data' to be accessible and set to our
  # data.
  # ---
  setScales = () ->
    yMax = d3.max(data, (d) -> d3.max(d.values, (e) -> e.value))
    # this scale is expanded past its max to provide some white space
    # on the top of the bars
    yScale.domain([0,yMax + 500000])

    names = data[0].values.map (d) -> d.name
    xScale.domain(names)
    colorScale.domain(names)

  # ---
  # Helper function to return the position
  # of a preview graph at index i
  # ---
  getPosition = (i) ->
    el = $('.preview')[i]
    # http://api.jquery.com/position/
    pos = $(el).position()
    pos

  return chart

# ---
# Given the div, data, and plot
# this function calls the plot in the
# fashion of the reusable chart example
# http://bost.ocks.org/mike/chart/
# ---
plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)

# Document is ready. Lets do this.
$ ->

  plot = SmallMults()
  display = (data) ->
    plotData("#vis", data, plot)

  d3.json("data/co2_kt_data.json", display)

