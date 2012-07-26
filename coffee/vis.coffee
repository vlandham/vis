
root = exports ? this

PropertyData = () ->
  data = null
  all = null
  dimensions = {}
  cap_rate = 0.04
  op_expense = 0.3
  all_rents = []

  filterData = {
    "building_rsf":
      min:3000
      max:4500000
      values:[3000,20500]
      ticks:[3000,8000,13000,20500,30500,46500,65000,100000,150000,280000,4500000]
    "government_leased":
      min:0
      max:100
      values:[30,70]
      ticks:[0,10,20,30,40,50,60,70,80,90,100]
    "government_rsf":
      min:3000
      max:2400000
      values:[3000,2400000]
      ticks:[3000,4500,6000,7500,9500,12000,16000,23000,38000,78000,2400000]
    "remaining_total_term":
      min:0
      max:20
      values:[0,6]
      ticks:[0,2,4,6,8,10,12,14,16,18,20]
    "remaining_firm_term":
      min:0
      max:20
      values:[0,10]
      ticks:[0,2,4,6,8,10,12,14,16,18,20]
    "total_rent":
      min:0
      max:71511980
      values:[0,71511980]
      ticks:[0,700000,1400000, 2100000, 2800000, 3500000, 4200000, 4900000, 5600000, 6300000, 7400000, 71511980]
    "rent_prsf":
      min:0
      max:250
      values:[0,250]
      ticks:[0,25,50,75,100,125,150,175,200,225,250]
  }

  clean = (rawData) ->
    fields = [
      "bldg_rsf"
      "percent_govt_leased"
      "total_leased_rsf"
      "remaining_total_term"
      "remaining_firm_term"
      "total_annual_rent"
      "rent_prsf"
    ]
    rawData.forEach (d) ->
      fields.forEach (f) ->
        d[f] = parseFloat(d[f])
    rawData

  stats = (data) ->
    fields = [
      "bldg_rsf"
      "percent_govt_leased"
      "total_leased_rsf"
      "remaining_total_term"
      "remaining_firm_term"
      "total_annual_rent"
      "rent_prsf"
    ]

    fields.forEach (field) ->
      ext = d3.extent(data, (d) -> d[field])
      console.log("#{field}: #{ext[0]} - #{ext[1]}")
      nums = data.map (d) -> d[field]
      # console.log(nums)
      nums.sort( d3.ascending)
      [0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0].forEach (i) ->
        q = d3.quantile(nums,i)
        console.log(" #{i}: #{q}")

    data

  pdata = (rawData) ->
    rawData = clean(rawData)
    # rawData = stats(rawData)
    data = crossfilter(rawData)
    all = data.groupAll()
    setupDimensions()
    # setupSliders()
    setupRangedSliders()

  setupRangedSliders = () ->
    d3.entries(filterData).forEach (entry) ->
      sliderId = "#slider_#{entry.key}"
      selectClass = "select_#{entry.key}"
      selecter = d3.select(sliderId)
        .append("select")
        .attr("class", selectClass)
        .style("display", "none")
      selecter.selectAll("option")
        .data(entry.value.ticks)
        .enter().append("option")
        .attr("value", (d) -> d)
        .attr("selected", (d) -> if entry.value.values[0] == d then "selected" else null)
        .text((d) -> fixUp(d))

      selecter = d3.select(sliderId)
        .append("select")
        .attr("class", selectClass)
        .style("display", "none")
      selecter.selectAll("option")
        .data(entry.value.ticks)
        .enter().append("option")
        .attr("value", (d) -> d)
        .attr("selected", (d) -> if entry.value.values[1] == d then "selected" else null)
        .text((d) -> d)

      $(".#{selectClass}").selectToUISlider({
        labels:0
        callback:'custom_slide'
      })
    $(root).bind('custom_slide', handleSlide)

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

  handleSlide = (event, sliderId, values) ->
    sliderId = sliderId.replace("slider_","")
    min = parseFloat(values[0]) - 1
    max = parseFloat(values[1]) + 1
    dimensions[sliderId].filter([min,max])
    # console.log("#{sliderId}:  #{min} - #{max}")
    $(root).trigger('filterupdate')

  setupDimensions = () ->
    dimensions.building_rsf = data.dimension (d) -> d.bldg_rsf
    dimensions.government_leased = data.dimension (d) -> parseFloat(d.percent_govt_leased)
    dimensions.government_rsf = data.dimension (d) -> d.total_leased_rsf
    dimensions.remaining_total_term = data.dimension (d) -> d.remaining_total_term
    dimensions.remaining_firm_term = data.dimension (d) -> d.remaining_firm_term
    dimensions.total_rent = data.dimension (d) -> d.total_annual_rent
    dimensions.rent_prsf = data.dimension (d) -> d.rent_prsf

    all_rents = dimensions.total_rent.top(Infinity).map((d) -> d.total_annual_rent).reverse()

    d3.entries(filterData).forEach (entry) ->
      dimensions[entry.key].filter(entry.value.values)

  pdata.data = () ->
    if dimensions.building_rsf
      dimensions.building_rsf.top(Infinity)
    else
      []

  pdata.capRate = (_) ->
    if !arguments.length
      return cap_rate
    cap_rate = _
    pdata

  pdata.opExpense = (_) ->
    if !arguments.length
      return op_expense
    op_expense = _
    pdata

  pdata.total_rsf = () ->
    if all
      all.reduceSum((d) -> d.total_leased_rsf).value()
    else
      0

  pdata.total_cap_value = () ->
    if all
      all.reduceSum((d) ->
        noi = d.total_annual_rent - (d.total_annual_rent * op_expense)
        noi / cap_rate
      ).value()
    else
      0

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

  tooltip = null


  circleRadius = 4

  usmap = (selection) ->
    tooltip = CustomTooltip("map_tooltip", 240)
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
      .attr("class", "location")
      .attr("cx", (d,i) -> positions[i][0])
      .attr("cy", (d,i) -> positions[i][1])
      .attr("r", circleRadius)
      .on("mouseover", (d,i) -> show_details(d,i,this))
      .on("mouseout", (d,i) -> hide_details(d,i,this))

    circle.exit().remove()

  show_details = (data, i, element) =>
    d3.select(element).classed("active", true)
    content = "<p class=\"main\">#{data.address}<br/>#{data.city}, #{data.state}</p><hr class=\"tooltip-hr\">"
    content +="<span class=\"name\">RSF:</span><span class=\"value\"> #{fixUp(data.bldg_rsf)}</span><br/>"
    content +="<span class=\"name\">Rent:</span><span class=\"value\"> #{data.rent_prsf}/RSF</span><br/>"
    tooltip.showTooltip(content,d3.event)

  hide_details = (data, i, element) =>
    d3.select(element).classed("active", false)
    tooltip.hideTooltip()


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
    $("#metric_rsf").text(fixUp(my_data.total_rsf()))
    $("#metric_cap_value").text(fixUp(my_data.total_cap_value()))
    my_map.update(filteredData)

  root.updateCap = () ->
    $("#metric_cap_value").text(fixUp(my_data.total_cap_value()))

  $(root).bind('filterupdate', update)

  plotData("#map",[], my_map)

  # $(".slider").slider({
  #   range:true,
  #   min:0,
  #   max:500,
  #   values: [75, 300]
  # })
  # $(".mini_slider").slider()
  setOpExpense = (event, parentID, values) ->
    my_data.opExpense(values[0])
    root.updateCap()

  setCapRate = (event, parentID, values) ->
    my_data.capRate(values[0])
    root.updateCap()

  $("#select_op_expense").selectToUISlider({
    labels:0
    callback:'set_op_expense'
  })
  $(root).bind('set_op_expense', setOpExpense)

  $("#select_cap_rate").selectToUISlider({
    labels:0
    callback:'set_cap_rate'
  })
  $(root).bind('set_cap_rate', setCapRate)


  $(".icon-question-sign").tipsy({gravity:'s', html:true, title: () -> "Here is a help popup.<br/>Help!."})


  display = (data) ->
    my_data(data)
    update()

  d3.csv("data/property_data.csv", display)

