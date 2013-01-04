
root = exports ? this

width = 900
height = 900

projection = d3.geo.albers()
  .center([0, 39.3])
  .rotate([94.58, 0])
  .scale(120000)
  .translate([width / 2, 0])

path = d3.geo.path().projection(projection)

# hexbin
hexbin = d3.hexbin()
  .size([width, height])
  .radius(6)
  # .x((d) -> projection([+d.lon, +d.lat])[0])
  # .y((d) -> projection([+d.lon, +d.lat])[1])

radius = d3.scale.sqrt()
  .domain([0,10])
  .range([0,3])

svg = d3.select("#vis").append("svg")
  .attr("width", width)
  .attr("height", height)

$ ->
  
  display_map = (geojson) ->
    tracts = svg.append("g")
      .attr("class", "tracts")

    tracts.selectAll("path").data(geojson.features).enter()
      .append("path")
      .attr("d", path)
      .attr("stroke", "#eee")
      .attr("fill", (d) -> if d.properties["STATEFP10"] == "20" then "#B5D9B9" else "#85C3C0")

  display_data = (data) ->
    svg.selectAll(".point").data(data).enter()
      .append("circle")
      .attr("class", "point")
      .attr("cx", (d) -> projection([d.lon,d.lat])[0])
      .attr("cy", (d) -> projection([d.lon,d.lat])[1])
      .attr("fill", "red")
      .attr("r", 2)

  display_stops = (data) ->
    converted_data = []
    data.forEach (d) ->
      p = projection([+d.stop_lon, +d.stop_lat])
      converted_data.push(p)
    hexs = hexbin(converted_data).sort((a,b) -> b.length - a.length)
    # radius.domain([0,hexs[0].length])
    console.log(radius.domain())

    svg.selectAll(".stop")
      .data(hexs).enter()
      .append("circle")
      .attr("class", "stop")
      .attr("transform", (d) -> "translate(#{d.x},#{d.y})")
      .attr("r", (d) -> radius(d.length))


  # hexbin
  display_hexbin = (data) ->

    converted_points = []
    data.forEach (d) ->
      p = projection([+d.lon, +d.lat])
      converted_points.push(p)
    
    hexs = hexbin(converted_points).sort((a,b) -> b.length - a.length)

    svg.selectAll(".hex")
      .data(hexs).enter()
      .append("circle")
      .attr("class", "hex")
      .attr("transform", (d) -> "translate(#{d.x},#{d.y})")
      .attr("r", (d) -> radius(d.length))

    svg.selectAll(".gon")
      .data(hexs).enter()
      .append("path")
      .attr("transform", (d) -> "translate(" + d.x + "," + d.y + ")")
      .attr("d", hexbin.hexagon())
      .attr("fill", "none")
      .attr("stroke", "black")

  display = (error, kc, data) ->
    console.log(error)
    display_map(kc)
    # display_data(data)
    # hexbin
    # display_hexbin(data)
    display_stops(data)
  
  queue()
    .defer(d3.json, "data/kc.json")
    # .defer(d3.csv, "data/fastfood.csv")
    .defer(d3.csv, "data/stops.txt")
    .await(display)

