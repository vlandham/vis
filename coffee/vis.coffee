
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
    d3.json "data/voroni_lat_lon.json", display_cells
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

  display_cells = (json) ->
    cells = vis.append("g")
      .attr("id", "cells")

    cells.selectAll("path")
      .data(json.features)
    .enter().append("path")
      .attr("d", path)
      .attr("fill-opacity", 0.5)
      .attr("fill", "#ddd")
      .attr("stroke", "#222")
    d3.csv "data/locations.csv", display_locations


  display_locations = (location_data) ->
    positions = []
    location_data.forEach (loc) ->
      # positions.push projection([+loc.lon, +loc.lat])
      positions.push [+loc.lon, +loc.lat]

    polygons = d3.geom.voronoi(positions)

    geo_polygons =
      "type": "FeatureCollection"
      "features": []

    # console.log(polygons)

    polygons.forEach (p, i) ->
      geo_poly =
        type: "Feature"
        properties: location_data[i]
        geometry:
          type: "Polygon"
          coordinates: [ p.map (p_element) -> p_element ]
      geo_polygons.features.push geo_poly

    root.geo = geo_polygons


    # console.log(geo_polygons)

    # cells = vis.append("g")
    #   .attr("class", "cells")
    #   .attr("id", "voronoi")

    # cell_gs = cells.selectAll("g")
    #     .data(location_data)
    #   .enter().append("g")

    # cell_gs.append("path")
    #   .attr("class", "cell")
    #   .attr("d", (d,i) -> "M#{polygons[i].join("L")}Z")


    locations = vis.append("g")
      .attr("class", "locations")
    locations.selectAll(".location")
      .data(location_data)
    .enter().append("circle")
      .attr("class", "location")
      .attr("cx", (d,i) -> positions[i][0])
      .attr("cy", (d,i) -> positions[i][1])
      .attr("r", 3.5)
    

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

