
root = exports ? this

$ ->

  w = 940
  h = 600
  r = 3
  [pt, pr, pb, pl] = [10, 10, 10, 10]

  proj = d3.geo.albersUsa().translate([-157872.20255447022, 65763.14090791851]).scale(3436985.607117489)
  path = d3.geo.path().projection(proj)
  translation = proj.translate()
  scale = proj.scale()

  data = null
  vis = null
  streets = null

  vis = d3.select("#vis")
    .append("svg")
    .attr("id", "vis-svg")
    .attr("width", w + (pl + pr))
    .attr("height", h + (pt + pb))

  render_streets = (json) ->
    data = json

    console.log(json)

    streets = vis.append("g")
      .attr("transform", "translate(#{pr},#{pt}")
      .attr("id", "streets")

    streets.selectAll("path")
      .data(json.features)
      .enter().append("path")
      .attr("d", path)
      .call(d3.behavior.zoom().on("zoom", redraw))

  redraw = () ->
    tx = translation[0] * d3.event.scale + d3.event.translate[0]
    ty = translation[1] * d3.event.scale + d3.event.translate[1]

    proj.translate([tx,ty])
    proj.scale(scale * d3.event.scale)
    console.log(proj.translate())
    console.log(proj.scale())

    streets.selectAll("path").attr("d", path)



  d3.json "data/troostwood.geojson", render_streets
