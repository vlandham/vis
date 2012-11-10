
root = exports ? this

Plot = () ->
  width = 600
  height = 600
  data = []
  points = null
  margin = {top: 20, right: 20, bottom: 20, left: 20}
  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([0,height])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)

  chart = (selection) ->
    selection.each (rawData) ->

      data = rawData

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      points = g.append("g").attr("id", "vis_points")
      update()

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

 # plot = Plot()
 # display = (data) ->
 #   plotData("#vis", data, plot)


 # d3.csv("data/test.csv", display)

 border = d3.selectAll(".border").append("svg")
   .attr("width", 940)
   .attr("height", 20)
 border.append("line")
   .attr("x1", 10)
   .attr("x2", 930)
   .attr("y1", 10)
   .attr("y2", 10)
   .style("stroke-width", 4)
   #.style("stroke", "#FFD340")
   .style("stroke", "#ddd")
   .style("stroke-linecap", "round")
   .style("stroke-dasharray", "1,12")

 options = {
   attribution: "",
   maxZoom: 18
 }

 KEY = "a901e8e6d6c04353895e2fede2d4a7c6"
 overbrook_location = [41.768037, -70.6021995]
 map = L.map('map').setView(overbrook_location, 16)
 L.tileLayer("http://{s}.tile.cloudmade.com/#{KEY}/997/256/{z}/{x}/{y}.png", options).addTo(map)
 
 marker = L.marker(overbrook_location).addTo(map)
 marker.bindPopup('<b>Overbrook House</b><br/>Bourne, MA')
 
 header = d3.selectAll(".fancy-header")
   .datum((d) -> d3.select(this).attr("data-header"))
   .call((d) -> console.log(this))
   .append("svg")
   .attr("width", 940)
   .attr("height", 40)

 header.append("line")
   .attr("x1", 10)
   .attr("x2", 930)
   .attr("y1", 10)
   .attr("y2", 10)
   .style("stroke-width", 4)
   .style("stroke", "#FFD340")

 header.append("line")
   .attr("x1", 10)
   .attr("x2", 930)
   .attr("y1", 20)
   .attr("y2", 20)
   .style("stroke-width", 4)
   .style("stroke", "#FFD340")

 header.append("rect")
   .style("fill", "white")
   .attr("x", (930 / 2) - 100)
   .attr("y", 0)
   .attr("width", 200)
   .attr("height", 40)

 header.append('text')
   .style("fill", '#555')
   .text((d) -> d)
   .attr("x", 930 / 2)
   .attr("y", 25)
   .style("text-anchor", "middle")
   .classed("script", true)
