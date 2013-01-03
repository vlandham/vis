
root = exports ? this

width = 900
height = 900

projection = d3.geo.albers()
  .center([0, 39.3])
  .rotate([94.58, 0])
  .scale(80000)
  .translate([width / 2, 0])

path = d3.geo.path().projection(projection)

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
    svg.selectAll("point").data(data).enter()
      .append("circle")
      .attr("cx", (d) -> projection([d.lat,d.lon])[0])
      .attr("cy", (d) -> projection([d.lat,d.lon])[1])
      .attr("r", 2)

  display = (error, kc, data) ->
    console.log(error)
    display_map(kc)
    display_data(data)
  
  queue()
    .defer(d3.json, "data/kc.json")
    .defer(d3.csv, "data/fastfood.csv")
    .await(display)

