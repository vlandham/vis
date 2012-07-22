
root = exports ? this

PropertyData = () ->
  data = null
  dimensions = null

  pdata = (rawData) ->
    data = crossfilter(rawData)
    setupDimensions()

  setupDimensions = () ->
    dimensions = {}
    dimensions.building_rsf = data.dimension (d) -> d.bldg_rsf
    dimensions.government_leased = data.dimension (d) -> d.percent_govt_leased
    dimensions.government_rsf = data.dimension (d) -> d.total_leased_rsf
    dimensions.remaining_total_term = data.dimension (d) -> d.remaining_total_term
    dimensions.remaining_firm_term = data.dimension (d) -> d.remaining_firm_term
    dimensions.total_rent = data.dimension (d) -> d.total_annual_rent
    dimensions.rent_prsf = data.dimension (d) -> d.rent_prsf

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

      circles = svg.append("g")
        .attr("id", "circles")

      d3.json "data/us-states.json", render_states
      update()


  update = () ->
    positions = []
    data.forEach (d) ->
      location = [d.longitude, d.latitude]
      positions.push(projection(location))

    circle = circles.selectAll("circle")
      .data(data)


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
  plotData("#map",[], my_map)

  $(".slider").slider({
    range:true,
    min:0,
    max:500,
    values: [75, 300]
  })
  $(".mini_slider").slider()

  display = (data) ->
    my_data(data)

  d3.csv("data/property_data.csv", display)

