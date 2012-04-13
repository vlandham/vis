
root = exports ? this

$ ->
  projection = d3.geo.albersUsa().translate([-900,950]).scale(28000)
  scale = projection.scale()
  translation = projection.translate()
  path = d3.geo.path().projection(projection)

  tracts = null
  locations = null

  vis = d3.select("#vis")
    .append("svg")
    .attr("width", 900)
    .attr("height", 900)

  display_tracts = (json) ->
    d3.csv "data/locations.csv", display_locations
    tracts = vis.append("g")
      .attr("id", "tracts")

    tracts.selectAll("path")
      .data(json.features)
    .enter().append("path")
      .attr("d", path)
      .attr("fill-opacity", 0.5)
      .attr("fill", (d) -> if d.properties["STATEFP10"] == "20" then "#B5D9B9" else "#85C3C0")
      .attr("stroke", "#222")
      .call(d3.behavior.zoom().on("zoom", redraw))

  display_locations = (location_data) ->
    positions = []
    location_data.forEach (loc) ->
      positions.push projection([+loc.lon, +loc.lat])

    polygons = d3.geom.voronoi(positions)

    cells = vis.append("g")
      .attr("class", "cells")
      .attr("id", "voronoi")

    cell_gs = cells.selectAll("g")
        .data(location_data)
      .enter().append("g")

    cell_gs.append("path")
      .attr("class", "cell")
      .attr("d", (d,i) -> "M#{polygons[i].join("L")}Z")


    locations = vis.append("g")
      .attr("class", "locations")
    locations.selectAll(".location")
      .data(location_data)
    .enter().append("circle")
      .attr("class", "location")
      .attr("cx", (d,i) -> positions[i][0])
      .attr("cy", (d,i) -> positions[i][1])
      .attr("r", 3.5)
      .on "mouseover", (d,i) ->
        console.log(d)


  redraw = () ->
    tx = translation[0] * d3.event.scale + d3.event.translate[0]
    ty = translation[1] * d3.event.scale + d3.event.translate[1]

    projection.translate([tx, ty])
    projection.scale(scale * d3.event.scale)

    tracts.selectAll("path").attr("d", path)

    locations.selectAll(".location")
      .attr("cx", (d,i) -> projection([+d.lon, +d.lat])[0])
      .attr("cy", (d,i) -> projection([+d.lon, +d.lat])[1])

  d3.json "data/kc_tracts.geojson", display_tracts

