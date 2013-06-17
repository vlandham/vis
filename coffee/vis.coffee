
root = exports ? this

Plot = () ->
  width = 600
  height = 800
  left_x = 200
  right_x = 400
  data = []

  all = []
  points = null
  margin = {top: 40, right: 5, bottom: 20, left: 5}
  yScaleLeft = d3.scale.linear().domain([0,10]).range([height,0])
  yScaleRight = d3.scale.linear().domain([0,10]).range([height,0])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(-d.pos)


  checkData = (data) ->
    hotels = {}
    bnbs = {}
    data.hotel.forEach (d) ->
      hotels[d.name] = yValue(d)
    data.bnb.forEach (d) ->
      bnbs[d.name] = yValue(d)

    d3.keys(hotels).forEach (h) ->
      b = bnbs[h]
      if !b
        console.log("no bnb entry for #{h}")

    d3.keys(bnbs).forEach (b) ->
      h = hotels[b]
      if !h
        console.log("no hotel entry for #{b}")

    d3.keys(hotels).forEach (h) ->
      all.push [hotels[h], bnbs[h]]

    yScaleLeft.domain(d3.extent(data.hotel, (d) -> yValue(d)))
    yScaleRight.domain(d3.extent(data.bnb, (d) -> yValue(d)))

  chart = (selection) ->
    selection.each (rawData) ->

      checkData(rawData)

      data = rawData

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      points = g.append("g").attr("id", "vis_points")
      svg.append("text")
        .text("Hotel Price Index")
        .attr("x", left_x)
        .attr("y", 20)
        .style("font-size", "120%")
        .attr("text-anchor", "middle")

      svg.append("text")
        .text("Airbnb Price Index")
        .attr("x", right_x)
        .attr("y", 20)
        .style("font-size", "120%")
        .attr("text-anchor", "middle")

      update()

  update = () ->

    points.selectAll(".cross")
      .data(all).enter()
      .append("line")
      .attr("class", (d) -> "cross")
      .attr("x1", left_x)
      .attr("y1", (d) -> yScaleLeft(d[0]))
      .attr("x2", right_x)
      .attr("y2", (d) -> yScaleRight(d[1]))
      .style("stroke", "#444")
      .style("stroke-width", 1.3)

    points.selectAll(".hotel")
      .data(data.hotel).enter()
      .append("circle")
      .attr("class", "hotel")
      .attr("cx", (d) -> left_x)
      .attr("cy", (d) -> yScaleLeft(yValue(d)))
      .attr("r", 4)
      .attr("fill", "steelblue")
      .style("stroke", "white")
      .style("stroke-width", 2)


    points.selectAll(".bnb")
      .data(data.bnb).enter()
      .append("circle")
      .attr("class", "bnb")
      .attr("cx", (d) -> right_x)
      .attr("cy", (d) -> yScaleRight(yValue(d)))
      .attr("r", 4)
      .attr("fill", "steelblue")
      .style("stroke", "white")
      .style("stroke-width", 2)

    points.selectAll(".title_left")
      .data(data.hotel).enter()
      .append("text")
      .attr("class", "title_left")
      .attr("x", left_x - 15)
      .attr("y", (d) -> yScaleLeft(yValue(d)))
      .attr("dy", 5)
      .attr("text-anchor", "end")
      .text((d) -> d.name)

    points.selectAll(".title_right")
      .data(data.bnb).enter()
      .append("text")
      .attr("class", "title_right")
      .attr("x", right_x + 15)
      .attr("y", (d) -> yScaleRight(yValue(d)))
      .attr("dy", 5)
      .attr("text-anchor", "start")
      .text((d) -> d.name)


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

  return chart

root.Plot = Plot

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)


$ ->

  plot = Plot()
  display = (error, hotel, bnb) ->
    data = {"hotel":hotel, "bnb":bnb}
    plotData("#vis", data, plot)

  queue()
    .defer(d3.csv, "data/avg_hotel.csv")
    .defer(d3.csv, "data/avg_bnb.csv")
    .await(display)

