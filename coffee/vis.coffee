
root = exports ? this

PropertyData = () ->
  data = null
  dimensions = {}

  filterData = {
    "building_rsf":
      min:3000
      max:800000
      values:[4000,300000]
    "government_leased":
      min:0
      max:100
      values:[0,100]
    "government_rsf":
      min:3000
      max:800000
      values:[4000,400000]
    "remaining_total_term":
      min:0
      max:20
      values:[0,20]
    "remaining_firm_term":
      min:0
      max:20
      values:[0,20]
  }

  pdata = (rawData) ->
    data = crossfilter(rawData)
    setupDimensions()
    setupSliders()

  setupSliders = () ->
    d3.entries(filterData).forEach (entry) ->
      sliderId = "#slider_#{entry.key}"
      $(sliderId).slider({
        range:true,
        min:entry.value.min,
        max:entry.value.max,
        values: entry.value.values
        slide: handleSlide
      })

  handleSlide = (event,ui) ->
    sliderId = $(this).attr("id").replace("slider_","")
    dimensions[sliderId].filter(ui.values)
    $(root).trigger('filterupdate')

  setupDimensions = () ->
    dimensions.building_rsf = data.dimension (d) -> d.bldg_rsf
    dimensions.government_leased = data.dimension (d) -> d.percent_govt_leased
    dimensions.government_rsf = data.dimension (d) -> d.total_leased_rsf
    dimensions.remaining_total_term = data.dimension (d) -> d.remaining_total_term
    dimensions.remaining_firm_term = data.dimension (d) -> d.remaining_firm_term
    dimensions.total_rent = data.dimension (d) -> d.total_annual_rent
    dimensions.rent_prsf = data.dimension (d) -> d.rent_prsf

    d3.entries(filterData).forEach (entry) ->
      dimensions[entry.key].filter(entry.value.values)

  pdata.data = () ->
    if dimensions.building_rsf
      dimensions.building_rsf.top(Infinity)
    else
      []

  pdata


USMap = () ->
  width = 620
  height = 430
  data = null
  dimensions = null
  filters = null
  circles = null
  circle = []
  states = null
  labels = null
  projection = null
  projection = d3.geo.albersUsa()
  path = d3.geo.path()

  circleRadius = 3

  usmap = (selection) ->
    selection.each (rawData) ->
      data = rawData

      projection.scale(width * 1.2)
        .translate([10, 0])

      path.projection(projection)

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      svg.attr("width", width)
      svg.attr("height", height)

      svg.append("rect")
        .attr("class", "background")
        .attr("width", width)
        .attr("height", height)

      g = svg.insert("g")
        .attr("transform", "translate(#{width / 2},#{height / 2})")

      states = g.append("g")
        .attr("id", "states")
        
      labels = g.append("g")
        .attr("id", "state-labels")

      circles = g.append("g")
        .attr("id", "circles")

      d3.json "data/us-states.json", render_states
      update()

  usmap.update = (newData) ->
    data = newData
    update()

  update = () ->
    positions = []
    data.forEach (d) ->
      location = [d.longitude, d.latitude]
      positions.push(projection(location))

    circle = circles.selectAll("circle")
      .data(data, (d) -> "#{d.longitude},#{d.latitude}")

    circle.enter().append("circle")
      .attr("cx", (d,i) -> positions[i][0])
      .attr("cy", (d,i) -> positions[i][1])
      .attr("r", circleRadius)

    circle.exit().remove()

  render_states = (states_json) ->
    states.selectAll("path")
      .data(states_json.features)
      .enter().append("path")
      .attr("d", path)

  usmap

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)

$ ->

  my_map = USMap()
  my_data = PropertyData()

  root.update = () ->
    filteredData = my_data.data()
    $("#metric_locations").text(addCommas(filteredData.length))
    my_map.update(filteredData)

  $(root).bind('filterupdate', update)

  plotData("#map",[], my_map)

  # $(".slider").slider({
  #   range:true,
  #   min:0,
  #   max:500,
  #   values: [75, 300]
  # })
  $(".mini_slider").slider()

  display = (data) ->
    my_data(data)
    update()

  d3.csv("data/property_data.csv", display)

