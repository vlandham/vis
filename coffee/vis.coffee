
root = exports ? this

Plot = () ->
  width = 960
  height = 500
  data = []
  us = {}
  zips = {}
  counties = {}
  points = null
  margin = {top: 0, right: 0, bottom: 0, left: 0}
  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([0,height])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)

  votes = d3.map()

  quantize = d3.scale.quantize()
    .domain([0,8])
    .range(d3.range(9).map (i) -> "q#{i}-9")

  path = d3.geo.path()

  countVotes = (data) ->
    data.forEach (d) ->
      vote_zip = +d["Answer.zipcode"]
      vote_county = zips[vote_zip]
      if vote_county
        votes[vote_county] ||= 0
        votes[vote_county] += 1
      else
        console.log("no county for #{vote_zip}")


  isCounty = (d) ->
    true

  chart = (selection) ->
    selection.each (rawData) ->

      data = rawData

      countVotes(data)
      console.log(votes)


      found = 0
      not_found = 0
      topojson.feature(us, us.objects.counties).features.forEach (f) ->
        if counties[f.id]
          found += 1
        else
          not_found += 1

      console.log("found counties: #{found}")
      console.log("not found counties: #{not_found}")

      console.log(counties)
      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      console.log(us)
      counties = g.append("g").attr("class", "counties")
        .selectAll("path")
        .data(topojson.feature(us, us.objects.counties).features)
        .enter().append("path")
        .attr "class", (d) ->
          count = votes[d.id]
          if count
            quantize(count + 1)
          else if isCounty(d)
            "q0-9"
          else
            "blank"

        .attr("d", path)

      g.append("path")
        .datum(topojson.mesh(us, us.objects.states, (a,b) -> a != b))
        .attr("class", "states")
        .attr("d", path)

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

  chart.us = (_) ->
    if !arguments.length
      return us
    us = _
    chart

  chart.zips = (_) ->
    if !arguments.length
      return zips
    console.log(_)
    zips = {}
    d3.entries(_).forEach (e) ->
      e.value.forEach (z) ->
        zips[+z] = +e.key
        counties[+e.key] = +z
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
  display = (error, data, zips, us) ->
    plot.zips(zips)
    plot.us(us)
    plotData("#vis", data, plot)

  queue()
    .defer(d3.csv, "data/results.csv")
    .defer(d3.json, "data/FIPS_to_ZIPS.json")
    .defer(d3.json, "data/us.json")
    .await(display)

